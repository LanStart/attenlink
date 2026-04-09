const { chromium } = require('playwright');

/**
 * Advanced Browser MCP Tool
 * Provides deep web searching and page analysis with JS support
 */
async function performDeepSearch(url) {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    console.log(`Navigating to ${url}...`);
    await page.goto(url, { waitUntil: 'networkidle' });

    // Handle lazy loading by scrolling
    await page.evaluate(async () => {
      await new Promise((resolve) => {
        let totalHeight = 0;
        let distance = 100;
        let timer = setInterval(() => {
          let scrollHeight = document.body.scrollHeight;
          window.scrollBy(0, distance);
          totalHeight += distance;
          if (totalHeight >= scrollHeight) {
            clearInterval(timer);
            resolve();
          }
        }, 100);
      });
    });

    // Extract structure and main content
    const data = await page.evaluate(() => {
      return {
        title: document.title,
        content: document.body.innerText.substring(0, 10000), // Cap content
        links: Array.from(document.querySelectorAll('a')).map(a => a.href).filter(h => h.startsWith('http')),
        meta: {
          description: document.querySelector('meta[name="description"]')?.content,
          ogTitle: document.querySelector('meta[property="og:title"]')?.content,
        }
      };
    });

    return data;
  } catch (error) {
    console.error(`Error during browser search: ${error}`);
    return { error: error.message };
  } finally {
    await browser.close();
  }
}

// Simple CLI runner for MCP integration
const args = process.argv.slice(2);
if (args[0] === 'search' && args[1]) {
  performDeepSearch(args[1]).then(data => {
    console.log(JSON.stringify(data, null, 2));
  });
}
