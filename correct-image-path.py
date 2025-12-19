from pathlib import Path
import re

# 这里改成你的 Quartz 输出目录
public_root = Path("public")  # 示例路径

pattern = re.compile(r'((src|href)=["\'])\.\./assets/')

for html in public_root.rglob("*.html"):
    text = html.read_text(encoding="utf-8")
    new_text = pattern.sub(r'\1./assets/', text)
    if new_text != text:
        html.write_text(new_text, encoding="utf-8")

