from PIL import Image, ImageDraw, ImageFont
import os

def create_tk_icon(size):
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
        font = ImageFont.truetype("C:/Windows/Fonts/IMPRISHA.TTF", font_size)
    except:
        try:
            font = ImageFont.truetype("arial.ttf", int(size * 0.35))
        except:
            font = ImageFont.load_default()
    
    # Draw "TK" text
    text = "TK"
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
android_path = "android/app/src/main/res"
for folder, size in android_sizes.items():
    icon = create_tk_icon(size)
    folder_path = os.path.join(android_path, folder)
    os.makedirs(folder_path, exist_ok=True)
    icon.save(os.path.join(folder_path, "ic_launcher.png"))
    print(f"Created {folder}/ic_launcher.png ({size}x{size})")

print("Mobile app icons generated successfully!")