import sys
import os

# Set stdout to utf-8 for Windows console
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass # Python 2 or other environment

try:
    from markitdown import MarkItDown
    md = MarkItDown()
    # Check if file exists
    file_path = r"e:\YuNotebooks\08_YGC\长江\南方医科大学特聘教授余光创 (7).pdf"
    if not os.path.exists(file_path):
        print(f"Error: File not found: {file_path}")
        sys.exit(1)
        
    result = md.convert(file_path)
    print(result.text_content)
except ImportError:
    print("Error: markitdown module not found. Please install it or use source markdown files.")
except Exception as e:
    print(f"Error converting file: {e}")
