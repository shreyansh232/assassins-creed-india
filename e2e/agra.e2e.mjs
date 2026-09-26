// e2e/agra.e2e.mjs — Issue #1: art pass looks realistic + slice logic intact.
// ponytail: plain node + playwright-core (Brave), no test framework.
import { spawn, execFile } from 'node:child_process';
import { chromium } from 'playwright-core';
import { promisify } from 'node:util';
const sh = promisify(execFile);
const ROOT = new URL('..', import.meta.url).pathname;
const BRAVE = '/Applications/Brave Browser.app/Contents/MacOS/Brave Browser';
let failures = 0;
const ok = (name, cond) => { console.log(`${cond ? 'PASS' : 'FAIL'}  ${name}`); if (!cond) failures++; };

// 1. Godot e2e slice: full clue -> infiltrate -> assassinate -> escape logic intact post-art.
const markers = { test_boot: 'BOOT_OK', test_player: 'PLAYER_OK', test_detection: 'DETECT_OK',
  test_blend: 'BLEND_OK', test_investigation: 'INVEST_OK', test_kill: 'KILL_OK',
  test_blockout_visuals: 'VISUALS_OK', test_scene_wiring: 'SCENE_OK', test_art_pass: 'ART_OK' };
for (const [t, want] of Object.entries(markers)) {
  try {
    const { stdout } = await sh('godot', ['--headless', '--path', ROOT, '-s', `tests/${t}.gd`], { timeout: 60000 });
    ok(`godot ${t} -> ${want}`, stdout.includes(want));
  } catch (e) { ok(`godot ${t} -> ${want} (ran)`, false); }
}

// 2. Serve report + drive it with Brave.
const srv = spawn('python3', ['-m', 'http.server', '8901'], { cwd: new URL('.', import.meta.url).pathname, stdio: 'ignore' });
await new Promise(r => setTimeout(r, 1200));
const browser = await chromium.launch({ executablePath: BRAVE });
const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
await page.goto('http://127.0.0.1:8901/report.html', { waitUntil: 'networkidle' });
await page.waitForFunction('window.__checks !== undefined', null, { timeout: 15000 });
ok('all acceptance checks green', await page.evaluate(() => Object.values(window.__checks).every(Boolean)));
ok('5 zones in stats', await page.evaluate(() => Object.keys(window.__stats.zones).length === 5));

// 3. Pixel realism on the actual Godot renders (same-origin canvas, no deps).
const px = await page.evaluate(() => {
  const stat = (id) => {
    const img = document.getElementById(id);
    const c = document.createElement('canvas');
    c.width = img.naturalWidth; c.height = img.naturalHeight;
    const x = c.getContext('2d');
    x.drawImage(img, 0, 0);
    const d = x.getImageData(0, 0, c.width, c.height).data;
    let red = 0, bright = 0, sum = 0, sum2 = 0, n = 0;
    for (let i = 0; i < d.length; i += 16) {
      const r = d[i] / 255, g = d[i + 1] / 255, b = d[i + 2] / 255;
      if (r > 0.45 && g < 0.38 && r > g + 0.12) red++;
      if (r > 0.75 && g > 0.72 && b > 0.65) bright++;
      const l = 0.3 * r + 0.6 * g + 0.1 * b;
      sum += l; sum2 += l * l; n++;
    }
    const mean = sum / n;
    return { w: c.width, red: red / n, bright: bright / n, std: Math.sqrt(sum2 / n - mean * mean), mean };
  };
  return { fort: stat('shot-fort'), taj: stat('shot-taj'), over: stat('shot-overview') };
});
ok('fort shot 1280px + sandstone red visible', px.fort.w === 1280 && px.fort.red > 0.05);
ok('taj shot marble white visible', px.taj.bright > 0.01);
ok('overview warm haze, varied (not blank)', px.over.std > 0.05 && px.over.mean > 0.45 && px.over.mean < 0.8);
ok('bazaar + ghats shots rendered', await page.evaluate(() =>
  document.getElementById('shot-bazaar').naturalWidth === 1280 &&
  document.getElementById('shot-ghats').naturalWidth === 1280));

// 4. Interaction: zone filter buttons dim/highlight correctly.
for (const z of ['fort', 'taj', 'bazaar', 'all']) {
  await page.click(`.filters button[data-zone="${z}"]`);
  const dimmed = await page.evaluate(() => document.querySelectorAll('figure.dim').length);
  ok(`filter "${z}" dims correctly`, z === 'all' ? dimmed === 0 : dimmed >= 1);
}
await page.screenshot({ path: 'shots/playwright-report.png', fullPage: true });
await browser.close();
srv.kill();
console.log(failures === 0 ? 'E2E_OK' : `E2E_FAIL(${failures})`);
process.exit(failures === 0 ? 0 : 1);
