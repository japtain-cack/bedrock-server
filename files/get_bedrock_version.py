#!/usr/bin/env python3

import re
from playwright.sync_api import sync_playwright


def get_latest_bedrock_info():
    with sync_playwright() as p:
        browser = p.firefox.launch(headless=True)
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        )
        page = context.new_page()
        page.goto("https://www.minecraft.net/en-us/download/server/bedrock")
        page.wait_for_load_state("networkidle")

        # Find the download link for Ubuntu Linux
        link_locator = page.locator("a[href*='bedrock-server'][href*='bin-linux']")
        download_url = link_locator.get_attribute("href")

        if not download_url:
            raise ValueError("Could not find the Ubuntu Linux download link")

        # Extract version from the URL
        version_match = re.search(r"bedrock-server-(\d+(?:\.\d+)+)\.zip", download_url)
        if version_match:
            version = version_match.group(1)
        else:
            version = "unknown"

        browser.close()
        return version, download_url


if __name__ == "__main__":
    version, download_link = get_latest_bedrock_info()
    print(version)
    print(download_link)
