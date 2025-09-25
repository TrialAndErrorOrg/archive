#!/usr/bin/env python3
"""
Script to fetch Crossref XML metadata for DOIs.

Usage:
    python get-xml.py                           # Search current directory for main.tex
    python get-xml.py /path/to/directory        # Search specific directory for main.tex
    python get-xml.py https://doi.org/10.36850/e10  # Fetch metadata for specific DOI URL
    python get-xml.py 10.36850/e10             # Fetch metadata for specific DOI
"""

import sys
import os
import re
import requests
import argparse
from pathlib import Path
from urllib.parse import urlparse


def extract_doi_from_tex(tex_file_path):
    """Extract DOI from \\paperdoi{} command in LaTeX file."""
    try:
        with open(tex_file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Look for \paperdoi{...} pattern
        match = re.search(r'\\paperdoi\{([^}]+)\}', content)
        if match:
            return match.group(1)
        
        return None
    except Exception as e:
        print(f"Error reading {tex_file_path}: {e}")
        return None


def is_url(string):
    """Check if string is a URL."""
    try:
        result = urlparse(string)
        return all([result.scheme, result.netloc])
    except:
        return False


def extract_doi_from_url(url):
    """Extract DOI from DOI URL."""
    # Handle various DOI URL formats
    if 'doi.org/' in url:
        return url.split('doi.org/')[-1]
    return url


def fetch_crossref_xml(doi):
    """Fetch XML metadata from Crossref API for given DOI."""
    if not doi:
        return None
    
    # Clean up DOI (remove any URL parts)
    if doi.startswith('http'):
        doi = extract_doi_from_url(doi)
    
    url = f"https://doi.org/{doi}"
    headers = {
        'Accept': 'application/vnd.crossref.unixsd+xml'
    }
    
    try:
        response = requests.get(url, headers=headers, allow_redirects=True)
        response.raise_for_status()
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"Error fetching metadata for DOI {doi}: {e}")
        return None


def find_main_tex(directory):
    """Find main.tex file or any .tex file in the given directory."""
    directory = Path(directory)
    
    # First try main.tex
    main_tex = directory / "main.tex"
    if main_tex.exists():
        return str(main_tex)
    
    # If not found, look for any .tex file
    tex_files = list(directory.glob("*.tex"))
    if tex_files:
        # If multiple .tex files, prefer ones with common names
        preferred_names = ['main.tex', 'article.tex', 'paper.tex']
        for preferred in preferred_names:
            for tex_file in tex_files:
                if tex_file.name == preferred:
                    return str(tex_file)
        
        # If no preferred names found, use the first .tex file
        print(f"No main.tex found, using {tex_files[0].name}")
        return str(tex_files[0])
    
    print(f"No .tex files found in {directory}")
    return None


def main():
    parser = argparse.ArgumentParser(description='Fetch Crossref XML metadata for DOIs')
    parser.add_argument('target', nargs='?', default='.', 
                       help='Directory path, DOI, or DOI URL (default: current directory)')
    parser.add_argument('-o', '--output', default='deposit.xml',
                       help='Output filename (default: deposit.xml)')
    
    args = parser.parse_args()
    
    doi = None
    
    # Determine what the target is
    if is_url(args.target):
        # It's a URL
        doi = extract_doi_from_url(args.target)
        print(f"Extracting DOI from URL: {doi}")
    elif os.path.isdir(args.target):
        # It's a directory
        tex_file = find_main_tex(args.target)
        if tex_file:
            doi = extract_doi_from_tex(tex_file)
            if doi:
                print(f"Found DOI in {tex_file}: {doi}")
            else:
                print(f"No \\paperdoi{{}} found in {tex_file}")
                return 1
        else:
            return 1
    elif os.path.isfile(args.target):
        # It's a file
        if args.target.endswith('.tex'):
            doi = extract_doi_from_tex(args.target)
            if doi:
                print(f"Found DOI in {args.target}: {doi}")
            else:
                print(f"No \\paperdoi{{}} found in {args.target}")
                return 1
        else:
            print(f"File {args.target} is not a .tex file")
            return 1
    else:
        # Assume it's a DOI
        doi = args.target
        print(f"Treating as DOI: {doi}")
    
    if not doi:
        print("No DOI found or provided")
        return 1
    
    # Fetch the XML
    xml_content = fetch_crossref_xml(doi)
    if xml_content:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(xml_content)
        print(f"XML metadata saved to {args.output}")
        return 0
    else:
        print("Failed to fetch XML metadata")
        return 1


if __name__ == '__main__':
    sys.exit(main())
