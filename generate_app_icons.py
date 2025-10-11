#!/usr/bin/env python3
"""
Generate Android app icons from a source image
"""

from PIL import Image, ImageDraw
import os

def create_rounded_icon(image, size):
    """Create a rounded icon with the specified size"""
    if not isinstance(size, int) or size <= 0 or size > 2048:
        raise ValueError("Invalid size parameter")
    
    # Create a new image with transparency
    rounded = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Resize the source image
    with image.resize((size, size), Image.Resampling.LANCZOS) as resized:
        # Create a circular mask
        mask = Image.new('L', (size, size), 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, size, size), fill=255)
        
        # Apply the mask
        rounded.paste(resized, (0, 0))
        rounded.putalpha(mask)
    
    return rounded

def generate_android_icons(source_path):
    """Generate all required Android icon sizes"""
    
    # Android icon sizes
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    # Foreground icon sizes (for adaptive icons)
    foreground_sizes = {
        'mipmap-mdpi': 108,
        'mipmap-hdpi': 162,
        'mipmap-xhdpi': 216,
        'mipmap-xxhdpi': 324,
        'mipmap-xxxhdpi': 432
    }
    
    # Validate and sanitize source path
    if not source_path or '..' in source_path or not isinstance(source_path, str):
        raise ValueError("Invalid source path")
    
    source_path = os.path.abspath(os.path.normpath(source_path))
    if not os.path.isfile(source_path):
        raise ValueError("Source file does not exist")
    
    try:
        # Load the source image
        with Image.open(source_path).convert('RGBA') as source:
            # Android res directory
            project_root = os.path.abspath('.')
            android_res = os.path.join(project_root, 'android', 'app', 'src', 'main', 'res')
            android_res = os.path.abspath(android_res)
            
            # Generate regular launcher icons
            for folder, size in sizes.items():
                # Sanitize folder name
                if not folder.replace('-', '').replace('_', '').isalnum():
                    continue
                
                folder_path = os.path.join(android_res, folder)
                folder_path = os.path.abspath(folder_path)
                
                # Validate folder path is within android_res
                if not folder_path.startswith(android_res):
                    continue
                
                os.makedirs(folder_path, exist_ok=True)
                
                # Create regular icon
                icon_path = os.path.join(folder_path, 'ic_launcher.png')
                icon_path = os.path.abspath(icon_path)
                
                if icon_path.startswith(folder_path):
                    with source.resize((size, size), Image.Resampling.LANCZOS) as icon:
                        icon.save(icon_path)
                    print(f"Generated {folder}/ic_launcher.png ({size}x{size})")
            
            # Generate foreground icons for adaptive icons
            for folder, size in foreground_sizes.items():
                # Sanitize folder name
                if not folder.replace('-', '').replace('_', '').isalnum():
                    continue
                
                folder_path = os.path.join(android_res, folder)
                folder_path = os.path.abspath(folder_path)
                
                # Validate folder path is within android_res
                if not folder_path.startswith(android_res):
                    continue
                
                os.makedirs(folder_path, exist_ok=True)
                
                # Create foreground icon (larger for adaptive icons)
                icon_path = os.path.join(folder_path, 'ic_launcher_foreground.png')
                icon_path = os.path.abspath(icon_path)
                
                if icon_path.startswith(folder_path):
                    with source.resize((size, size), Image.Resampling.LANCZOS) as foreground:
                        foreground.save(icon_path)
                    print(f"Generated {folder}/ic_launcher_foreground.png ({size}x{size})")
            
            print("Android app icons generated successfully!")
        
    except Exception as e:
        print(f"Error generating icons: {e}")
        raise

if __name__ == "__main__":
    # You'll need to save your POS icon image as 'pos_icon.png' in the project root
    source_image = os.path.abspath("pos_icon.png")
    
    if os.path.exists(source_image):
        generate_android_icons(source_image)
    else:
        print(f"Source image '{source_image}' not found!")
        print("Please save your POS icon image as 'pos_icon.png' in the project root directory.")