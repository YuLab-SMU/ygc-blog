from pathlib import Path


def has_frontmatter(text: str) -> bool:
    # 去掉 UTF-8 BOM 和文件开头的空行
    text = text.lstrip("\ufeff")
    lines = text.splitlines()
    i = 0
    while i < len(lines) and lines[i].strip() == "":
        i += 1
    if i >= len(lines):
        return False
    return lines[i].strip() == "---"


def main() -> None:
    repo_root = Path(__file__).resolve().parent.parent
    count = 0

    for md in repo_root.rglob("*.md"):
        try:
            text = md.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue

        if has_frontmatter(text):
            continue

        new_text = "---\npublish: false\n---\n\n" + text
        md.write_text(new_text, encoding="utf-8")
        count += 1
        print(f"added frontmatter: {md.relative_to(repo_root)}")

    print(f"\nDone. Updated {count} markdown files.")


if __name__ == "__main__":
    main()

