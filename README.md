# JOTE Archive

# Scripts

## Setup

Ideally install [uv](https://docs.astral.sh/uv/) and run the following commands:

```bash
uv sync
cp .env.example .env  # Add your DOAJ_API_TOKEN
```

or if you know better you probably know how to run a python script.

## get-xml.py

Fetches Crossref XML metadata for DOIs. Can be used to manually deposit files to DOAJ after setting their DOI.

```bash
uv run python scripts/get-xml.py                    # current directory
uv run python scripts/get-xml.py /path/to/dir       # specific directory
uv run python scripts/get-xml.py 10.36850/e10       # specific DOI
```

## doaj-submit.py

Submits articles to DOAJ from LaTeX files.

Will update it if the article already exists in DOAJ. The DOI is treated as the unique identifier, make sure `\paperdoi{}` is set in the main.tex file.

```bash
uv run python scripts/doaj-submit.py --dry-run      # test run
uv run python scripts/doaj-submit.py                # submit to DOAJ
uv run python scripts/doaj-submit.py issues/path/to/main.tex                # submit specific article
```

Extracts: DOI, title, abstract, keywords, authors+ORCID, affiliations, journal info, dates.
