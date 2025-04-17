from flask import Flask, jsonify
import os
import requests
from bs4 import BeautifulSoup

scrape_url = os.getenv("SCRAPE_URL", "https://fallback-url.com")
print(f"Scraping from URL: {scrape_url}")

# Scrape title dynamically
def scrape_title(url):
    try:
        response = requests.get(url, timeout=5)
        soup = BeautifulSoup(response.text, 'html.parser')
        title = soup.title.string.strip() if soup.title else "No title found"
        return {"url": url, "title": title}
    except Exception as e:
        return {"url": url, "error": str(e)}

app = Flask(__name__)

@app.route('/')
def home():
    scraped_data = scrape_title(scrape_url)
    return jsonify(scraped_data)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
