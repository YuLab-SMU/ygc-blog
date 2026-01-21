import requests
from bs4 import BeautifulSoup
from markdownify import markdownify as md
import re
import os
import time
import random

def clean_filename(title):
    # Remove invalid characters for Windows filenames
    return re.sub(r'[\\/*?:"<>|]', "", title)

def scrape_wechat_article(url, output_dir="."):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    
    try:
        print(f"Fetching: {url}")
        response = requests.get(url, headers=headers, timeout=10)
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
        title_tag = soup.find('meta', property='og:title')
        title = title_tag['content'] if title_tag else "Untitled Article"

    # Clean title for filename
    safe_title = clean_filename(title)
    
    # Check if file already exists
    filename = os.path.join(output_dir, f"{safe_title}.md")
    if os.path.exists(filename):
        print(f"Skipping (already exists): {filename}")
        return

    # Extract date
    # WeChat often puts date in a JS variable or hidden field. 
    # Attempting to find publish_time
    date = "Unknown Date"
    scripts = soup.find_all('script')
    for script in scripts:
        if script.string and 'ct =' in script.string:
            # Look for timestamp like ct = "1600000000"
            match = re.search(r'ct\s*=\s*"(\d+)"', script.string)
            if match:
                timestamp = int(match.group(1))
                date = time.strftime('%Y-%m-%d', time.localtime(timestamp))
                break
    
    # Extract Author
    author_tag = soup.find('meta', property='og:article:author')
    author = author_tag['content'] if author_tag else "Unknown Author"

    # Extract content
    content_div = soup.find('div', class_='rich_media_content')
    
    if not content_div:
        print("Could not find article content.")
        return

    # Handle images: WeChat uses data-src for lazy loading
    for img in content_div.find_all('img'):
        if 'data-src' in img.attrs:
            img['src'] = img['data-src']
            del img['data-src']
            
    # Remove style tags and scripts from content
    for tag in content_div(['script', 'style']):
        tag.decompose()

    # Convert to HTML string then Markdown
    html_content = str(content_div)
    markdown_content = md(html_content, heading_style="ATX")

    # Clean up Markdown
    # Remove excessive newlines
    markdown_content = re.sub(r'\n{3,}', '\n\n', markdown_content)

    # Prepare Frontmatter
    frontmatter = f"""---
title: "{title}"
url: {url}
date: {date}
author: {author}
tags:
  - WeChat
---

"""
    
    final_content = frontmatter + markdown_content
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(final_content)
    
    print(f"Saved: {filename}")

def main():
    # File containing URLs (one per line)
    url_file = "urls.txt"
    output_dir = "downloaded_articles"
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    urls = []
    
    if os.path.exists(url_file):
        with open(url_file, 'r', encoding='utf-8') as f:
            urls = [line.strip() for line in f if line.strip().startswith('http')]
    else:
        print(f"Warning: {url_file} not found. Using default example URLs.")
        urls = [
            "https://mp.weixin.qq.com/s/YSUaqDdc0dNDzX2upM87Fg",
        ]

    print(f"Found {len(urls)} URLs to process.")
    
    for i, url in enumerate(urls):
        scrape_wechat_article(url, output_dir)
        # Sleep to be nice to WeChat servers
        time.sleep(random.uniform(1, 3))

if __name__ == "__main__":
    main()
