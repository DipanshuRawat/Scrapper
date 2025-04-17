const puppeteer = require('puppeteer-core');
const path = require('path');
const scrapeUrl = process.env.SCRAPE_URL;

if (!scrapeUrl) {
  console.error('No URL provided!');
  process.exit(1);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/chromium-browser',  // Specify the correct executable path
    headless: true,  // Run in headless mode
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.goto(scrapeUrl);

  // Take a screenshot
  // await page.screenshot({ path: '/app/src/node/screenshot.png', fullPage: true });
  
  const data = await page.evaluate(() => {
    const title = document.title;
    const heading = document.querySelector('h1') ? document.querySelector('h1').textContent : null;
    return { title, heading };
  });

  console.log(data);

  const fs = require('fs');
  fs.writeFileSync('scraped_data.json', JSON.stringify(data, null, 2));

  await browser.close();
})();
