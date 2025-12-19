from pathlib import Path
import shutil

# 设置根目录，假设脚本位于根目录的上一级或同级
public_root = (Path(__file__).resolve().parent / "docs").resolve()

if not public_root.is_dir():
    raise SystemExit(f"public directory not found: {public_root}")

def has_html_file(directory: Path) -> bool:
    """检查目录下是否有 .html 文件（不递归）"""
    try:
        for _ in directory.glob("*.html"):
            return True
    except OSError:
        pass
    return False

def process_directory(current_dir: Path) -> bool:
    """
    递归处理目录：
    返回 True 表示该目录应该保留。
    返回 False 表示该目录已被移除。
    """
    
    # 1. 优先检查特殊规则：如果是 assets 且父目录有 HTML
    # 如果满足条件，则保留当前目录及其所有子内容（不递归进入删除检查）
    if current_dir.name == 'assets':
        if has_html_file(current_dir.parent):
            return True

    # 2. 基础判断：当前目录是否有 HTML
    should_keep = has_html_file(current_dir)
    
    # 3. 递归处理所有子目录 (Post-order traversal)
    try:
        subdirs = [p for p in current_dir.iterdir() if p.is_dir()]
    except OSError as e:
        print(f"Error accessing {current_dir}: {e}")
        return True # 无法访问时保守保留

    for subdir in subdirs:
        # 递归调用处理子目录
        # 如果子目录被保留，则当前目录也必须保留
        if process_directory(subdir):
            should_keep = True
            
    # 4. 根目录保护
    if current_dir == public_root:
        return True

    # 5. 执行删除或保留
    if not should_keep:
        print(f"Removing: {current_dir.relative_to(public_root)}")
        try:
            shutil.rmtree(current_dir)
        except OSError as e:
            print(f"Failed to remove {current_dir}: {e}")
        return False
    else:
        return True

print(f"Starting cleanup on: {public_root}")
process_directory(public_root)
print("Cleanup finished.")