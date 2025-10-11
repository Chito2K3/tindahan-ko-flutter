from PIL import Image, ImageDraw, ImageFont
import os

def create_tk_icon(size):
    # Validate size parameter
    if not isinstance(size, int) or size <= 0 or size > 2048:
        raise ValueError("Invalid size parameter")
    
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Pink gradient background (circular)
    center = size // 2
    radius = center - 2
    
    # Create circular background with pink gradient
    for i in range(radius):
        alpha = int(255 * (1 - i / radius))
        color = (236, 72, 153, alpha)  # Pink color with varying alpha
        draw.ellipse([center - radius + i, center - radius + i, 
                     center + radius - i, center + radius - i], 
                    fill=color)
    
    # Draw solid pink circle
    draw.ellipse([center - radius, center - radius, 
                 center + radius, center + radius], 
                fill=(236, 72, 153, 255))
    
    # Try to load Imperial Script font, fallback to default
    try:
        font_size = int(size * 0.4)
        # Use relative path or system fonts only
        font = ImageFont.truetype("arial.ttf", font_size)
    except (OSError, IOError):
        try:
            font = ImageFont.load_default()
        except Exception:
            font = None
    
    # Draw "TK" text
    text = "TK"
    if font:
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = (size - text_width) // 2
        y = (size - text_height) // 2 - int(size * 0.02)
        
        # White text with slight shadow
        draw.text((x + 1, y + 1), text, fill=(0, 0, 0, 100), font=font)
        draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    return img

# Android icon sizes
android_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192
}

# Create Android icons
project_root = os.path.abspath('.')
android_path = os.path.join(project_root, "android", "app", "src", "main", "res")

for folder, size in android_sizes.items():
    # Sanitize folder name
    if not folder.replace('-', '').replace('_', '').isalnum():
        continue
    
    icon = create_tk_icon(size)
    folder_path = os.path.join(android_path, folder)
    folder_path = os.path.abspath(folder_path)
    
    # Validate path is within android directory
    if folder_path.startswith(android_path):
        os.makedirs(folder_path, exist_ok=True)
        icon_path = os.path.join(folder_path, "ic_launcher.png")
        icon.save(icon_path)
        print(f"Created {folder}/ic_launcher.png ({size}x{size})")

print("Mobile app icons generated successfully!")