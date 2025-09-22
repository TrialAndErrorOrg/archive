#!/usr/bin/env python3
"""
Script to parse main.tex files and submit/update articles to DOAJ API.

Usage:
    python doaj-submit.py                       # Process current directory
    python doaj-submit.py /path/to/directory    # Process specific directory
    python doaj-submit.py main.tex              # Process specific tex file
"""

import sys
import os
import re
import json
import requests
from pathlib import Path
from datetime import datetime
from urllib.parse import quote
from dotenv import load_dotenv
import html
import difflib
import tempfile
import subprocess

# Load environment variables
load_dotenv()


def extract_balanced_braces(text, start_pos):
    """Extract content between balanced braces starting at start_pos."""
    if start_pos >= len(text) or text[start_pos] != '{':
        return None
    
    brace_count = 0
    i = start_pos
    while i < len(text):
        char = text[i]
        if char == '\\':
            # Skip escaped characters
            i += 2
            continue
        elif char == '{':
            brace_count += 1
        elif char == '}':
            brace_count -= 1
            if brace_count == 0:
                return text[start_pos + 1:i]
        i += 1
    
    return None  # Unbalanced braces


def clean_latex_text(text):
    """Clean LaTeX commands and escape sequences from text."""
    if not text:
        return text
    
    # Handle common LaTeX subscripts and superscripts
    text = re.sub(r'\\textsubscript\{([^}]+)\}', r'_\1', text)
    text = re.sub(r'\\textsuperscript\{([^}]+)\}', r'^\1', text)
    text = re.sub(r'\\textbf\{([^}]+)\}', r'\1', text)
    text = re.sub(r'\\textit\{([^}]+)\}', r'\1', text)
    text = re.sub(r'\\emph\{([^}]+)\}', r'\1', text)
    
    # Handle common LaTeX symbols
    text = text.replace('\\&', '&')
    text = text.replace('\\%', '%')
    text = text.replace('\\$', '$')
    text = text.replace('\\_', '_')
    text = text.replace('\\#', '#')
    
    # Remove other LaTeX commands
    text = re.sub(r'\\[a-zA-Z]+\{[^}]*\}', '', text)
    text = re.sub(r'\\[a-zA-Z]+', '', text)
    
    # Clean up braces and backslashes
    text = re.sub(r'[{}\\]', '', text)
    
    # Clean up multiple spaces
    text = re.sub(r'\s+', ' ', text).strip()
    
    # Decode HTML entities if any
    text = html.unescape(text)
    
    return text


def validate_article_data(metadata, article_json):
    """Validate extracted data and check for issues."""
    issues = []
    missing_fields = []
    
    # Check for missing essential fields
    essential_fields = ['doi', 'title', 'abstract', 'authors']
    for field in essential_fields:
        if field not in metadata or not metadata[field]:
            missing_fields.append(field)
    
    # Check for LaTeX sequences in the stringified JSON
    json_str = json.dumps(article_json, indent=2)
    latex_patterns = [
        r'\\[a-zA-Z]+\{[^}]*\}',  # LaTeX commands
        r'\\[a-zA-Z]+',           # LaTeX commands without braces
        r'\\textsubscript',       # Specific commands
        r'\\textsuperscript',
        r'\\emph',
        r'\\textbf',
        r'\\textit'
    ]
    
    latex_issues = []
    for pattern in latex_patterns:
        matches = re.findall(pattern, json_str)
        if matches:
            latex_issues.extend(set(matches))  # Remove duplicates
    
    return {
        'missing_fields': missing_fields,
        'latex_sequences': latex_issues,
        'issues': issues
    }


def show_diff(existing_article, new_article):
    """Show diff between existing and new article data."""
    # Extract comparable data (exclude timestamps and IDs)
    def clean_for_comparison(article):
        if not article:
            return {}
        cleaned = article.get('bibjson', {}).copy()
        # Remove fields that always change
        cleaned.pop('last_updated', None)
        cleaned.pop('created_date', None)
        return cleaned
    
    existing_clean = clean_for_comparison(existing_article)
    new_clean = clean_for_comparison(new_article)
    
    existing_str = json.dumps(existing_clean, indent=2, sort_keys=True)
    new_str = json.dumps(new_clean, indent=2, sort_keys=True)
    
    diff = difflib.unified_diff(
        existing_str.splitlines(keepends=True),
        new_str.splitlines(keepends=True),
        fromfile='Existing in DOAJ',
        tofile='New submission',
        lineterm=''
    )
    
    return ''.join(diff)


def edit_json_interactively(article_json):
    """Allow user to edit the JSON in their preferred editor."""
    # Create a temporary file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as temp_file:
        json.dump(article_json, temp_file, indent=2)
        temp_file_path = temp_file.name
    
    try:
        # Get the user's preferred editor
        editor = os.environ.get('EDITOR', 'nano')  # Default to nano if no EDITOR set
        
        print(f"\nOpening JSON in {editor}...")
        print("Save and exit when you're done editing.")
        
        # Open the editor
        result = subprocess.run([editor, temp_file_path], check=True)
        
        # Read the modified JSON
        with open(temp_file_path, 'r') as f:
            try:
                edited_json = json.load(f)
                print("✓ JSON successfully parsed after editing")
                return edited_json
            except json.JSONDecodeError as e:
                print(f"✗ Invalid JSON after editing: {e}")
                response = input("JSON is invalid. Use original version? [Y/n]: ").strip().lower()
                if response in ['n', 'no']:
                    return None
                return article_json
                
    except subprocess.CalledProcessError:
        print("Editor exited with error. Using original JSON.")
        return article_json
    except FileNotFoundError:
        print(f"Editor '{editor}' not found. Using original JSON.")
        print("Set EDITOR environment variable to your preferred editor.")
        return article_json
    finally:
        # Clean up the temporary file
        try:
            os.unlink(temp_file_path)
        except OSError:
            pass


def preview_and_confirm(article_json, existing_article=None, validation_result=None, interactive=True):
    """Show preview and get user confirmation. Returns (confirmed, article_json)."""
    print("\n" + "="*80)
    print("ARTICLE SUBMISSION PREVIEW")
    print("="*80)
    
    # Show validation issues first
    if validation_result:
        if validation_result['missing_fields']:
            print("\n⚠️  MISSING FIELDS:")
            for field in validation_result['missing_fields']:
                print(f"   - {field}")
        
        if validation_result['latex_sequences']:
            print("\n⚠️  LATEX SEQUENCES FOUND:")
            for seq in validation_result['latex_sequences'][:10]:  # Show first 10
                print(f"   - {seq}")
            if len(validation_result['latex_sequences']) > 10:
                print(f"   ... and {len(validation_result['latex_sequences']) - 10} more")
    
    # Show article preview
    bibjson = article_json.get('bibjson', {})
    print(f"\nTitle: {bibjson.get('title', 'N/A')}")
    print(f"DOI: {bibjson.get('identifier', [{}])[0].get('id', 'N/A')}")
    print(f"Authors: {len(bibjson.get('author', []))} author(s)")
    for i, author in enumerate(bibjson.get('author', [])[:3], 1):
        print(f"   {i}. {author.get('name', 'N/A')} ({author.get('affiliation', 'No affiliation')[:50]}...)")
    if len(bibjson.get('author', [])) > 3:
        print(f"   ... and {len(bibjson.get('author', [])) - 3} more authors")
    
    print(f"Keywords: {', '.join(bibjson.get('keywords', []))}")
    print(f"Abstract: {bibjson.get('abstract', 'N/A')[:200]}...")
    
    # Show diff if updating existing article
    if existing_article:
        print("\n" + "-"*80)
        print("CHANGES FROM EXISTING ARTICLE:")
        print("-"*80)
        diff = show_diff(existing_article, article_json)
        if diff:
            print(diff)
        else:
            print("No changes detected.")
    
    print("\n" + "="*80)
    
    # Get user confirmation
    if not interactive:
        return False, article_json  # Don't proceed in non-interactive mode
    
    while True:
        if existing_article:
            action = "update"
        else:
            action = "create"
        
        try:
            response = input(f"Do you want to {action} this article in DOAJ? [y/N/show-full/edit]: ").strip().lower()
        except EOFError:
            print("\nNo input available (non-interactive mode)")
            return False, article_json
        
        if response in ['y', 'yes']:
            return True, article_json
        elif response in ['n', 'no', '']:
            return False, article_json
        elif response in ['show-full', 'full', 'show']:
            print("\n" + "="*80)
            print("FULL ARTICLE JSON:")
            print("="*80)
            print(json.dumps(article_json, indent=2))
            print("="*80)
            continue
        elif response in ['edit', 'e']:
            edited_json = edit_json_interactively(article_json)
            if edited_json is None:
                print("Editing cancelled.")
                continue
            elif edited_json != article_json:
                print("JSON has been modified.")
                # Update the article_json for future operations
                article_json.clear()
                article_json.update(edited_json)
                # Re-validate the edited JSON
                validation_result = validate_article_data({}, article_json)
                # Show updated preview
                print("\n" + "="*80)
                print("UPDATED ARTICLE PREVIEW:")
                print("="*80)
                if validation_result['latex_sequences']:
                    print("\n⚠️  LATEX SEQUENCES FOUND:")
                    for seq in validation_result['latex_sequences'][:10]:
                        print(f"   - {seq}")
                bibjson = article_json.get('bibjson', {})
                print(f"\nTitle: {bibjson.get('title', 'N/A')}")
                print(f"DOI: {bibjson.get('identifier', [{}])[0].get('id', 'N/A')}")
                print(f"Authors: {len(bibjson.get('author', []))} author(s)")
                continue
            else:
                print("No changes made to JSON.")
                continue
        else:
            print("Please enter 'y' for yes, 'n' for no, 'show-full' to see the complete JSON, or 'edit' to modify the JSON.")


def extract_metadata_from_tex(tex_file_path):
    """Extract article metadata from LaTeX file."""
    try:
        with open(tex_file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        metadata = {}
        
        # Extract various fields using regex patterns
        patterns = {
            'doi': r'\\paperdoi\{([^}]+)\}',
            'title': r'\\jotetitle\{([^}]+)\}',
            'keywords': r'\\keywordsabstract\{([^}]+)\}',
            'abstract': r'\\abstracttext\{(.*?)\}',
            'journal_name': r'\\jname\{([^}]+)\}',
            'year': r'\\jyear\{([^}]+)\}',
            'volume': r'\\jvolume\{([^}]+)\}',
            'issue': r'\\jissue\{([^}]+)\}',
            'pages': r'\\jpages\{([^}]+)\}',
            'published_date': r'\\paperpublisheddate\{([^}]+)\}',
            'received_date': r'\\paperreceived\{([^}]+)\}',
            'accepted_date': r'\\paperaccepted\{([^}]+)\}',
            'website': r'\\jwebsite\{([^}]+)\}',
        }
        
        for key, pattern in patterns.items():
            if key in ['abstract', 'title', 'keywords']:
                # Use balanced brace extraction for fields that might contain nested braces
                command = key if key != 'abstract' else 'abstracttext'
                if key == 'title':
                    command = 'jotetitle'
                elif key == 'keywords':
                    command = 'keywordsabstract'
                
                match = re.search(rf'\\{command}\{{', content)
                if match:
                    start_pos = match.end() - 1  # Position of opening brace
                    extracted_text = extract_balanced_braces(content, start_pos)
                    if extracted_text:
                        metadata[key] = clean_latex_text(extracted_text.strip())
            else:
                # Simple regex for other fields
                match = re.search(pattern, content)
                if match:
                    raw_text = match.group(1).strip()
                    metadata[key] = clean_latex_text(raw_text)
        
        # Special handling for abstract in older format \\begin{abstract}...\\end{abstract}
        if 'abstract' not in metadata or not metadata['abstract']:
            abstract_match = re.search(r'\\begin\{abstract\}(.*?)\\end\{abstract\}', content, re.DOTALL)
            if abstract_match:
                abstract_text = abstract_match.group(1).strip()
                metadata['abstract'] = clean_latex_text(abstract_text)
        
        # Extract authors and affiliations with better matching
        authors = []
        
        # Find all author and affil lines with their indices
        # Use a simpler approach - extract each author line individually
        author_lines = []
        affil_lines = []
        
        for line in content.split('\n'):
            line = line.strip()
            if line.startswith('\\author['):
                author_lines.append(line)
            elif line.startswith('\\affil['):
                affil_lines.append(line)
        
        # Parse author lines
        author_matches = []
        for line in author_lines:
            # Extract indices and content
            indices_match = re.search(r'\\author\[([^\]]*)\]', line)
            content_match = re.search(r'\\author\[[^\]]*\]\{(.+)\}+$', line)
            if indices_match and content_match:
                raw_indices = indices_match.group(1)
                # Extract only numeric indices, ignore \\authfn{} and other non-numeric content
                numeric_indices = re.findall(r'\d+', raw_indices)
                indices = ','.join(numeric_indices)
                content_text = content_match.group(1)
                author_matches.append((indices, content_text))
        
        # Parse affil lines  
        affil_matches = []
        for line in affil_lines:
            indices_match = re.search(r'\\affil\[([^\]]*)\]', line)
            content_match = re.search(r'\\affil\[[^\]]*\]\{(.+)\}$', line)
            if indices_match and content_match:
                indices = indices_match.group(1)
                content_text = clean_latex_text(content_match.group(1))
                affil_matches.append((indices, content_text))
        
        # Create a mapping of affiliation indices to affiliation text
        affil_map = {}
        for affil_indices, affil_text in affil_matches:
            # Split indices by comma in case there are multiple
            indices = [idx.strip() for idx in affil_indices.split(',')]
            for idx in indices:
                affil_map[idx] = affil_text.strip()
        
        # Process each author
        for author_indices, author_text in author_matches:
            author = {}
            
            # Parse author indices (can be comma-separated like "1,2,3")
            indices = [idx.strip() for idx in author_indices.split(',')]
            
            # Extract author content
            if '\\mbox{' in author_text:
                # Extract everything after \mbox{
                mbox_content = re.search(r'\\mbox\{(.+)', author_text)
                if mbox_content:
                    author_content = mbox_content.group(1)
                else:
                    author_content = author_text
            else:
                author_content = author_text
            
            # Extract ORCID if present
            orcid_match = re.search(r'\\orcid\{([^}]+)\}', author_content)
            if orcid_match:
                author['orcid_id'] = orcid_match.group(1)
            
            # Clean up name step by step
            name = author_content
            # First remove ORCID
            name = re.sub(r'\\orcid\{[^}]+\}', '', name)
            # Use the general cleaning function
            name = clean_latex_text(name)
            author['name'] = name
            
            # Collect affiliations for this author based on their indices
            affiliations = []
            for idx in indices:
                if idx in affil_map:
                    affiliations.append(affil_map[idx])
            
            # Join multiple affiliations with semicolon
            if affiliations:
                author['affiliation'] = '; '.join(affiliations)
            
            authors.append(author)
        
        metadata['authors'] = authors
        
        return metadata
        
    except Exception as e:
        print(f"Error reading {tex_file_path}: {e}")
        return None


def search_doaj_article(doi, auth_token=None):
    """Search for existing article in DOAJ by DOI."""
    if not doi:
        return None
    
    # URL encode the DOI for the search
    encoded_doi = quote(f"doi:{doi}", safe='')
    url = f"https://doaj.org/api/search/articles/{encoded_doi}"
    
    headers = {'accept': 'application/json'}
    params = {}
    if auth_token:
        params['api_key'] = auth_token
    
    try:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        
        if data.get('total', 0) > 0:
            return data['results'][0]
        return None
        
    except requests.exceptions.RequestException as e:
        print(f"Error searching DOAJ for DOI {doi}: {e}")
        return None


def resolve_doi_url(doi):
    """Resolve DOI to actual article URL."""
    if not doi:
        return None
    
    try:
        url = f"https://doi.org/{doi}"
        response = requests.get(url, allow_redirects=False)
        
        if response.status_code in [301, 302, 303, 307, 308]:
            return response.headers.get('Location')
        elif response.status_code == 200:
            # Check for HTML redirect
            if 'text/html' in response.headers.get('content-type', ''):
                match = re.search(r'<a href="([^"]+)">', response.text)
                if match:
                    return match.group(1)
        
        # Fallback to constructed URL
        return f"https://journal.trialanderror.org/pub/{doi.split('/')[-1]}"
        
    except Exception:
        # Fallback to constructed URL
        return f"https://journal.trialanderror.org/pub/{doi.split('/')[-1]}"


def create_doaj_article_json(metadata):
    """Create DOAJ article JSON structure from extracted metadata."""
    if not metadata:
        return None
    
    # Parse keywords
    keywords = []
    if 'keywords' in metadata:
        keywords = [clean_latex_text(k.strip()) for k in metadata['keywords'].split(',')]
    
    # Parse pages
    start_page = None
    end_page = None
    if 'pages' in metadata:
        pages = metadata['pages'].replace('--', '-').replace('—', '-')
        if '-' in pages:
            parts = pages.split('-', 1)
            start_page = parts[0].strip()
            end_page = parts[1].strip()
        else:
            start_page = pages.strip()
    
    # Parse published date
    month = None
    year = metadata.get('year', '')
    if 'published_date' in metadata:
        try:
            # Try to parse date in YYYY-MM-DD format
            date_obj = datetime.strptime(metadata['published_date'], '%Y-%m-%d')
            month = str(date_obj.month)
            year = str(date_obj.year)
        except ValueError:
            # If parsing fails, use the year from jyear
            pass
    
    # Build the article JSON
    article = {
        "bibjson": {
            "title": metadata.get('title', ''),
            "abstract": metadata.get('abstract', ''),
            "author": [],
            "identifier": [
                {
                    "type": "doi",
                    "id": metadata.get('doi', '')
                },
                {
                    "type": "eissn",
                    "id": "2667-1204"
                }
            ],
            "journal": {
                "title": metadata.get('journal_name', 'Journal of Trial and Error').replace('\\&', '&'),
                "publisher": "JOTE Publishers",
                "country": "NL",  # Netherlands
                "language": ["EN"],
                "volume": metadata.get('volume', ''),
                "number": metadata.get('issue', ''),
            },
            "keywords": keywords,
            "link": [
                {
                    "type": "fulltext",
                    "url": resolve_doi_url(metadata.get('doi', '')),
                    "content_type": "HTML"
                }
            ],
            "year": year,
            "subject": [
                {
                    "scheme": "LCC",
                    "term": "Science (General)",
                    "code": "Q1-390"
                }
            ]
        }
    }
    
    # Add month if available
    if month:
        article["bibjson"]["month"] = month
    
    # Add pages if available
    if start_page:
        article["bibjson"]["journal"]["start_page"] = start_page
    if end_page:
        article["bibjson"]["journal"]["end_page"] = end_page
    
    # Add authors
    for author_data in metadata.get('authors', []):
        author = {
            "name": author_data.get('name', ''),
            "affiliation": author_data.get('affiliation', '')
        }
        if 'orcid_id' in author_data and author_data['orcid_id']:
            # Ensure ORCID is in full URL format
            orcid = author_data['orcid_id']
            if not orcid.startswith('https://orcid.org/'):
                orcid = f"https://orcid.org/{orcid}"
            author['orcid_id'] = orcid
        
        article["bibjson"]["author"].append(author)
    
    return article


def submit_to_doaj(article_json, existing_article=None, auth_token=None):
    """Submit or update article in DOAJ."""
    if not auth_token:
        print("No DOAJ API token found. Set DOAJ_API_TOKEN in .env file")
        return None
    
    headers = {
        'Content-Type': 'application/json'
    }
    
    if existing_article:
        # Update existing article
        article_id = existing_article['id']
        url = f"https://doaj.org/api/articles/{article_id}?api_key={auth_token}"
        
        # Check if anything has changed (excluding timestamps)
        existing_bibjson = existing_article.get('bibjson', {})
        new_bibjson = article_json.get('bibjson', {})
        
        # Simple comparison (could be more sophisticated)
        if json.dumps(existing_bibjson, sort_keys=True) == json.dumps(new_bibjson, sort_keys=True):
            print("No changes detected, skipping update")
            return existing_article
        
        print(f"Updating existing article {article_id}")
        try:
            response = requests.put(url, headers=headers, json=article_json)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error updating article: {e}")
            if hasattr(e.response, 'text'):
                print(f"Response: {e.response.text}")
            return None
    else:
        # Create new article
        url = f"https://doaj.org/api/articles?api_key={auth_token}"
        print("Creating new article")
        try:
            response = requests.post(url, headers=headers, json=article_json)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error creating article: {e}")
            if hasattr(e.response, 'text'):
                print(f"Response: {e.response.text}")
            return None


def find_main_tex(directory):
    """Find main.tex file in the given directory."""
    directory = Path(directory)
    main_tex = directory / "main.tex"
    
    if main_tex.exists():
        return str(main_tex)
    
    print(f"No main.tex found in {directory}")
    return None


def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Submit articles to DOAJ from LaTeX files')
    parser.add_argument('target', nargs='?', default='.', 
                       help='Directory path or .tex file (default: current directory)')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what would be submitted without actually submitting')
    
    args = parser.parse_args()
    
    # Find the tex file
    tex_file = None
    if os.path.isdir(args.target):
        tex_file = find_main_tex(args.target)
    elif os.path.isfile(args.target) and args.target.endswith('.tex'):
        tex_file = args.target
    else:
        print(f"Invalid target: {args.target}")
        return 1
    
    if not tex_file:
        return 1
    
    # Extract metadata
    print(f"Parsing {tex_file}...")
    metadata = extract_metadata_from_tex(tex_file)
    if not metadata:
        print("Failed to extract metadata")
        return 1
    
    print(f"Found article: {metadata.get('title', 'Unknown title')}")
    print(f"DOI: {metadata.get('doi', 'No DOI')}")
    
    if not metadata.get('doi'):
        print("No DOI found, cannot proceed")
        return 1
    
    # Get auth token
    auth_token = os.getenv('DOAJ_API_TOKEN')
    if not auth_token and not args.dry_run:
        print("No DOAJ API token found. Set DOAJ_API_TOKEN in .env file to submit to DOAJ")
        return 1
    
    # Check if article already exists
    print("Checking if article exists in DOAJ...")
    existing_article = search_doaj_article(metadata['doi'], auth_token)
    
    if existing_article:
        print(f"Found existing article with ID: {existing_article['id']}")
    else:
        print("Article not found in DOAJ")
    
    # Create DOAJ article JSON
    article_json = create_doaj_article_json(metadata)
    if not article_json:
        print("Failed to create article JSON")
        return 1
    
    # Validate the data
    validation_result = validate_article_data(metadata, article_json)
    
    if args.dry_run:
        print("\n--- DRY RUN ---")
        # Show preview and validation in dry run mode (non-interactive)
        _, _ = preview_and_confirm(article_json, existing_article, validation_result, interactive=False)
        return 0
    
    # Submit to DOAJ
    if not auth_token:
        print("Set DOAJ_API_TOKEN in .env file to submit to DOAJ")
        print("\n--- Article JSON ---")
        print(json.dumps(article_json, indent=2))
        return 1
    
    # Show preview and get confirmation
    confirmed, article_json = preview_and_confirm(article_json, existing_article, validation_result)
    if not confirmed:
        print("Submission cancelled by user.")
        return 0
    
    result = submit_to_doaj(article_json, existing_article, auth_token)
    if result:
        print(f"Successfully {'updated' if existing_article else 'created'} article")
        print(f"Article ID: https://doaj.org/article/{result.get('id', 'Unknown')}")
        return 0
    else:
        print("Failed to submit article")
        return 1


if __name__ == '__main__':
    sys.exit(main())
