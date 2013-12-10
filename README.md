wikinewsdemo
============

Demo of aspect of amcat. Needs to be reworked.

It performs the following:

1. Creates an empty database in Amcat
2. Scrapes articles from `en.wikinews.org`.
3. Serializes the articles in json format.
4. Re-creates an empty database in Amcat.
5. Loads the scraped articles from the json serialization

Current state:

- The scraper itself (`en_wikinews_org_scraper.py`) is not (yet) part of this repository.
- The scraper scrapes, but the articles do not show up in Amcat.
- The scripts are coded in Nuweb, but there is no explanation about how to use nuweb.

