import re
import time
from ddgs import DDGS

file_path = "e:/YuNotebooks/08_YGC/长江/指导.md"

with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

missing_names = []
for i, line in enumerate(lines):
    # Match lines like "- **王伟财**: 未找到中山大学官网介绍"
    match = re.search(r'- \*\*([^*]+)\*\*: 未找到', line)
    if match:
        missing_names.append((i, match.group(1)))

print(f"Found {len(missing_names)} missing names.")

results = {}
with DDGS(proxy="http://127.0.0.1:7897", timeout=15) as ddgs:
    for i, name in missing_names:
        query = f'{name} 中山大学'
        found = False
        try:
            for r in ddgs.text(query, max_results=3):
                title = r['title']
                href = r['href']
                body = r['body']
                # clean up newlines in title
                title = title.replace('\n', '').replace('\r', '')
                team = "（可能在大团队下）" if "团队" in body or "团队" in title else ""
                results[i] = f"- **{name}**: [{title}]({href}) {team}\n"
                found = True
                break
            if not found:
                results[i] = f"- **{name}**: 全网未检索到中山大学相关信息\n"
        except Exception as e:
            results[i] = f"- **{name}**: 全网未检索到中山大学相关信息 ({e})\n"
        print(f"Processed {name}")
        time.sleep(1)

for i, name in missing_names:
    if i in results:
        lines[i] = results[i]

with open(file_path, "w", encoding="utf-8") as f:
    f.writelines(lines)

print("Done")
