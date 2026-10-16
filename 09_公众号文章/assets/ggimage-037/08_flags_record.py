"""Hover across the flags; capture tooltip changes."""
import asyncio, os, shutil, glob
from playwright.async_api import async_playwright

BASE = os.path.dirname(os.path.abspath(__file__))
SRC = "file://" + os.path.join(BASE, "flags_interactive.html")
OUT = os.path.join(BASE, "seq")

CURSOR = """
(() => {
  const d = document.createElement('div');
  d.id = 'fakecursor';
  d.style.cssText = 'position:fixed;left:0;top:0;width:22px;height:22px;' +
    'pointer-events:none;z-index:99999;display:none;' +
    'background:url("data:image/svg+xml;utf8,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22><path d=%22M3 2 L3 19 L8 14.5 L11.5 21.5 L14.5 20 L11 13.5 L18 13 Z%22 fill=%22black%22 stroke=%22white%22 stroke-width=%221.6%22/></svg>") no-repeat;' +
    'filter:drop-shadow(0 1px 2px rgba(0,0,0,.5));';
  document.documentElement.appendChild(d);
  addEventListener('mousemove', e => {
    d.style.display = 'block';
    d.style.transform = `translate(${e.clientX}px, ${e.clientY}px)`;
  }, true);
})();
"""

async def main():
    shutil.rmtree(OUT, ignore_errors=True)
    os.makedirs(OUT)
    async with async_playwright() as pw:
        b = await pw.chromium.launch(
            executable_path="/usr/bin/microsoft-edge-stable",
            args=["--no-sandbox", "--force-color-profile=srgb"])
        pg = await (await b.new_context(viewport={"width": 740, "height": 480},
                                        device_scale_factor=2)).new_page()
        await pg.goto(SRC)
        await pg.wait_for_timeout(1500)
        await pg.evaluate(CURSOR)

        f = 0
        async def shot():
            nonlocal f
            f += 1
            await pg.screenshot(path=f"{OUT}/{f:03d}.png")

        async def glide(x0, y0, x1, y1, steps=9):
            for i in range(1, steps + 1):
                t = i / steps
                e = 1 - (1 - t) ** 3
                await pg.mouse.move(x0 + (x1 - x0) * e, y0 + (y1 - y0) * e)
                await pg.wait_for_timeout(30)
                await shot()

        async def hold(ms=700, n=5):
            for _ in range(n):
                await pg.wait_for_timeout(ms // n)
                await shot()

        ids = ["Switzerland", "Austria", "Netherlands", "Norway", "United States"]
        pos = []
        for name in ids:
            el = pg.locator(f"[data-id='{name}']")
            bb = await el.bounding_box()
            pos.append((bb["x"] + bb["width"] / 2, bb["y"] + bb["height"] / 2))

        await pg.mouse.move(60, 420)
        cur = (60, 420)
        for i, (x, y) in enumerate(pos):
            await glide(*cur, x, y)
            cur = (x, y)
            await hold()
            tip = await pg.evaluate(
                """() => { const t = document.querySelector('div[class*="tooltip"]');
                    return t && t.style.display !== 'none' ? t.innerText.trim() : null; }""")
            print(f"RESULT hover {ids[i]:14s} tooltip = {repr(tip)}")

        await b.close()
    print(f"RESULT frames = {f}")

    # 合成 GIF（ImageMagick），再清掉中间帧
    import subprocess
    gif = os.path.join(BASE, "flags_demo.gif")
    subprocess.run(["convert"] + sorted(glob.glob(os.path.join(OUT, "*.png"))) +
                   ["-delay", "7", "-loop", "0", "-resize", "640x",
                    "-layers", "Optimize", gif], check=True)
    shutil.rmtree(OUT)
    print(f"RESULT gif = {gif} ({os.path.getsize(gif) / 1024:.0f} KB)")

asyncio.run(main())
