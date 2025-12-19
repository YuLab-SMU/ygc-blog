from pathlib import Path
import shutil

# 假设脚本和 public 在同一级目录；也可以改成绝对路径
public_root = (Path(__file__).resolve().parent / "public").resolve()

if not public_root.is_dir():
    raise SystemExit(f"public directory not found: {public_root}")

# 收集所有 html 文件及其所有祖先目录
html_files = list(public_root.rglob("*.html"))
# 存储所有需要保留的目录
preserved_dirs = set()

for html_file in html_files:
    current_dir = html_file.parent
    while current_dir != public_root.parent: # 向上遍历直到 public_root 的父目录
        preserved_dirs.add(current_dir)
        if current_dir == public_root: # 包含 public_root 本身
            break
        current_dir = current_dir.parent

deleted_count = 0

# 按深度从深到浅遍历目录，避免父目录先删掉导致子目录找不到
# 排除 public_root 本身，因为它不应该被删除
all_dirs = [p for p in public_root.rglob("*") if p.is_dir() and p != public_root]
all_dirs.sort(key=lambda p: len(p.parts), reverse=True)

for d in all_dirs:
    if d not in preserved_dirs:
        print(f"Removing directory without HTML: {d.relative_to(public_root)}")
        shutil.rmtree(d)
        deleted_count += 1

print(f"Done. Removed {deleted_count} directories.")
