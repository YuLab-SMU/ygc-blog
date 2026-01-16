import requests
from bs4 import BeautifulSoup
from markdownify import markdownify as md
import re
import os

def scrape_wechat_article(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
    except Exception as e:
        print(f"Error fetching URL: {e}")
        return

    soup = BeautifulSoup(response.content, 'html.parser')

    # Extract title
    title_tag = soup.find('h1', class_='rich_media_title')
    if title_tag:
        title = title_tag.get_text(strip=True)
    else:
        # Fallback for title
        title_tag = soup.find('meta', property='og:title')
        title = title_tag['content'] if title_tag else "Untitled Article"

    # Extract date and author
    meta_content = soup.find('div', class_='rich_media_meta_list')
    date = ""
    author = ""
    if meta_content:
        # This part is tricky as WeChat structure changes, sometimes date is in JS
        # Looking for publish time in scripts
        pass
    
    # Extract content
    content_div = soup.find('div', class_='rich_media_content')
    
    if not content_div:
        print("Could not find article content.")
        return

    # Handle images: WeChat uses data-src for lazy loading
    for img in content_div.find_all('img'):
        if 'data-src' in img.attrs:
            img['src'] = img['data-src']
            # Remove data-src to clean up
            del img['data-src']

    # Convert to HTML string then Markdown
    html_content = str(content_div)
    markdown_content = md(html_content, heading_style="ATX")

    # Clean up some WeChat specific artifacts in Markdown if needed
    # Remove excessive newlines
    markdown_content = re.sub(r'\n{3,}', '\n\n', markdown_content)

    # Prepare Frontmatter
    frontmatter = f"""---
title: {title}
url: {url}
date: 2020-09-14 # Approximate date based on content or fetch current date
tags:
  - R
  - visualization
  - plotbb
---

"""
    
    final_content = frontmatter + markdown_content
    
    # Save to file
    filename = f"{title}.md"
    # Remove invalid characters from filename
    filename = re.sub(r'[\\/*?:"<>|]', "", filename)
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(final_content)
    
    print(f"Successfully saved article to: {filename}")

if __name__ == "__main__":
    urls = [
        "https://mp.weixin.qq.com/s/YSUaqDdc0dNDzX2upM87Fg",
        "https://mp.weixin.qq.com/s/xrogUDNQdl33vmQ9f_K0pQ",
        "https://mp.weixin.qq.com/s/51qmaNG4RthL3xDta8F2Ew"
    ]
    for url in urls:
        print(f"Scraping: {url}")
        scrape_wechat_article(url)
