from PIL import Image, ImageDraw, ImageFont
import os

def create_tk_icon(size, filename):
    # Create image with gradient background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient effect (simplified)
    for y in range(size):
        ratio = y / size
        r = int(233 * (1 - ratio) + 173 * ratio)  # E91E63 to AD1457
        g = int(30 * (1 - ratio) + 20 * ratio)
        b = int(99 * (1 - ratio) + 87 * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # Add border
    border_width = max(1, size // 64)
    draw.rectangle([border_width, border_width, size-border_width, size-border_width], 
                   outline=(255, 255, 255, 255), width=border_width)
    
    # Try to use a cursive font, fallback to default
    try:
        font_size = size // 2
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        font_size = size // 3
        font = ImageFont.load_default()
    
    # Draw "TK" text
    text = "TK"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    # Add shadow
    shadow_offset = max(1, size // 128)
    draw.text((x + shadow_offset, y + shadow_offset), text, 
              fill=(0, 0, 0, 128), font=font)
    
    # Draw main text
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    img.save(filename)
    print(f"Created {filename}")

# Create different sizes
sizes = [16, 32, 48, 96, 192, 512]
for size in sizes:
    create_tk_icon(size, f"web/icons/Icon-{size}.png")

# Create favicon.ico (16x16)
create_tk_icon(16, "web/favicon.png")
print("All icons created successfully!")