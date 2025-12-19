const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-accelerated-2d-canvas',
      '--no-first-run',
      '--no-zygote',
      '--single-process',
      '--disable-gpu',
      '--disable-blink-features=AutomationControlled'
    ]
  });
  const page = await browser.newPage();
  await page.evaluateOnNewDocument(() => {
    Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
  });
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  await page.goto('https://www.minecraft.net/en-us/download/server/bedrock', { waitUntil: 'networkidle2' });
  await page.waitForSelector('a[href*="bedrock-server"][href*="bin-linux"]');
  const link = await page.$eval('a[href*="bedrock-server"][href*="bin-linux"]', el => el.href);
  const versionMatch = link.match(/bedrock-server-([\d.]+)\.zip/);
  const version = versionMatch ? versionMatch[1] : 'unknown';
  console.log(version);
  await browser.close();
})();
