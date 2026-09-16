import os
from PIL import Image, ImageDraw

script_dir = os.path.dirname(os.path.abspath(__file__))
output_dir = os.path.join(script_dir, "Shared", "Assets.xcassets", "AppIcon.appiconset")

sizes = [16, 32, 64, 128, 256, 512, 1024]
for size in sizes:
    # Create a solid blue square image with RGB (no alpha)
    img = Image.new('RGB', (size, size), color=(0, 122, 255))
    draw = ImageDraw.Draw(img)
    # Draw a white circle in the middle
    margin = size // 4
    draw.ellipse([margin, margin, size - margin, size - margin], fill=(255, 255, 255))
    img.save(os.path.join(output_dir, f"icon-{size}.png"), format="PNG")
print("Icons generated.")
