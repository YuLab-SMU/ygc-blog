import os
import zipfile
import shutil
from PIL import Image

def compress_image(filepath, max_size_kb=150):
    max_size_bytes = max_size_kb * 1024
    
    try:
        file_size = os.path.getsize(filepath)
        if file_size <= max_size_bytes:
            return False

        print(f"Compressing {os.path.basename(filepath)}: {file_size/1024:.2f}KB -> Target: {max_size_kb}KB")
        
        with Image.open(filepath) as img:
            img_format = img.format
            
            quality = 90
            width, height = img.size
            temp_filepath = filepath + ".temp"
            current_width, current_height = width, height
            
            iteration = 0
            max_iterations = 20
            
            while True:
                iteration += 1
                if iteration > max_iterations:
                    break

                resize_needed = False
                if img_format == 'PNG':
                    resize_needed = True
                elif quality < 30:
                    resize_needed = True
                else:
                    quality -= 10

                if resize_needed:
                    current_width = int(current_width * 0.8)
                    current_height = int(current_height * 0.8)
                    if current_width < 50 or current_height < 50: 
                        break
                    img_to_save = img.resize((current_width, current_height), Image.Resampling.LANCZOS)
                else:
                    img_to_save = img

                try:
                    if img_format == 'JPEG':
                        img_to_save.save(temp_filepath, format='JPEG', quality=quality)
                    elif img_format == 'PNG':
                        img_to_save.save(temp_filepath, format='PNG', optimize=True)
                    else:
                        img_to_save.save(temp_filepath, format=img_format)
                except Exception as save_err:
                    break

                new_size = os.path.getsize(temp_filepath)
                
                if new_size <= max_size_bytes:
                    break
            
            if os.path.exists(temp_filepath):
                final_size = os.path.getsize(temp_filepath)
                if final_size < file_size:
                    shutil.move(temp_filepath, filepath)
                    return True
                else:
                    os.remove(temp_filepath)
                    return False
            return False

    except Exception as e:
        print(f"Error compressing {filepath}: {e}")
        if os.path.exists(filepath + ".temp"):
            os.remove(filepath + ".temp")
        return False

def process_docx(input_docx, output_docx, max_img_size_kb=150):
    work_dir = input_docx + "_working"
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)
    os.makedirs(work_dir)

    print(f"Extracting {input_docx}...")
    try:
        with zipfile.ZipFile(input_docx, 'r') as zip_ref:
            zip_ref.extractall(work_dir)
    except zipfile.BadZipFile:
        print("Error: Input file is not a valid zip/docx file.")
        return

    media_dir = os.path.join(work_dir, 'word', 'media')
    if os.path.exists(media_dir):
        files = os.listdir(media_dir)
        print(f"Found {len(files)} files in media directory.")
        for filename in files:
            if filename.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp', '.tiff')):
                filepath = os.path.join(media_dir, filename)
                compress_image(filepath, max_img_size_kb)

    print(f"Repacking to {output_docx}...")
    try:
        with zipfile.ZipFile(output_docx, 'w', zipfile.ZIP_DEFLATED) as zip_out:
            for root, dirs, files in os.walk(work_dir):
                for file in files:
                    full_path = os.path.join(root, file)
                    arcname = os.path.relpath(full_path, work_dir)
                    zip_out.write(full_path, arcname)
    except Exception as e:
        print(f"Error repacking: {e}")
        return

    print("Cleaning up...")
    shutil.rmtree(work_dir)
    print("Done.")

if __name__ == "__main__":
    input_file = r"e:\YuNotebooks\08_YGC\长江\附件证明材料大纲.docx"
    output_file = r"e:\YuNotebooks\08_YGC\长江\附件证明材料大纲-compressed.docx"
    process_docx(input_file, output_file, 150)
