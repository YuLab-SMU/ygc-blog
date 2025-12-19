from pathlib import Path
import re

# 这里改成你的 Quartz 输出目录
public_root = Path("docs")  # 示例路径

# 匹配一次或多次 ../ 后面跟着 assets/
pattern = re.compile(r'(\.\./)+assets/') 

print(f"Searching for HTML files in: {public_root.resolve()}")

for html_file in public_root.rglob("*.html"):
    print(f"Processing file: {html_file}")
    text = html_file.read_text(encoding="utf-8")
    
    # 检查是否找到匹配项
    if pattern.search(text):
        print(f"  Found pattern in {html_file}")
        # 将匹配到的 ../../assets/ 等全部替换为 ./assets/
        new_text = pattern.sub(r'./assets/', text) 
        if new_text != text:
            print(f"  Replacing content in {html_file}")
            html_file.write_text(new_text, encoding="utf-8")
        else:
            print(f"  Pattern found but no change made in {html_file}")
    else:
        print(f"  No pattern found in {html_file}")

print("Script finished.")