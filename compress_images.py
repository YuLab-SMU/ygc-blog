import os
from PIL import Image
import sys

def compress_images(directory, max_size_kb=150):
    max_size_bytes = max_size_kb * 1024
    supported_formats = ('.jpg', '.jpeg', '.png')
    
    for filename in os.listdir(directory):
        if not filename.lower().endswith(supported_formats):
            continue
            
        filepath = os.path.join(directory, filename)
        file_size = os.path.getsize(filepath)
        
        if file_size <= max_size_bytes:
            print(f"Skipping {filename}: {file_size/1024:.2f}KB (<= {max_size_kb}KB)")
            continue
            
        print(f"Processing {filename}: {file_size/1024:.2f}KB -> Target: {max_size_kb}KB")
        
        try:
            with Image.open(filepath) as img:
                # Convert RGBA to RGB if saving as JPEG (though we try to keep original format)
                # But for PNGs, if we need to compress heavily, sometimes we might need to change mode or just resize.
                
                # We will try to reduce quality first (for JPEGs) or resize
                quality = 95
                current_size = file_size
                
                # Create a temporary file to check size
                temp_filepath = filepath + ".temp"
                
                # Iterative compression
                while current_size > max_size_bytes:
                    if quality < 20: # If quality is too low, start resizing
                         width, height = img.size
                         img = img.resize((int(width * 0.9), int(height * 0.9)), Image.Resampling.LANCZOS)
                    else:
                        quality -= 5
                        
                    # Save to temp
                    if filename.lower().endswith(('.jpg', '.jpeg')):
                        img.save(temp_filepath, "JPEG", quality=quality)
                    else:
                        # PNG compression is harder with PIL alone, usually involves resizing or reducing colors (P mode)
                        # For now, let's try resizing if it's a PNG and too big
                        if filename.lower().endswith('.png'):
                             # If it's PNG, quality param doesn't work well for size. 
                             # We must resize.
                             if quality > 80: # Just a flag to start resizing immediately for PNG
                                 quality = 10 # Force resize path next loop if just started
                                 continue
                             width, height = img.size
                             img = img.resize((int(width * 0.9), int(height * 0.9)), Image.Resampling.LANCZOS)
                             img.save(temp_filepath, "PNG", optimize=True)
                        else:
                             img.save(temp_filepath, "JPEG", quality=quality)
                    
                    current_size = os.path.getsize(temp_filepath)
                    print(f"  ...trying quality={quality}/resize: {current_size/1024:.2f}KB")
                    
                    if width < 100 or height < 100: # Safety break
                        break

                # Replace original
                os.replace(temp_filepath, filepath)
                print(f"Compressed {filename} to {current_size/1024:.2f}KB")
                
        except Exception as e:
            print(f"Error processing {filename}: {e}")
            if os.path.exists(filepath + ".temp"):
                os.remove(filepath + ".temp")

if __name__ == "__main__":
    target_dir = r"e:\YuNotebooks\08_YGC\x\word\media"
    compress_images(target_dir)
