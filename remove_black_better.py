from PIL import Image

def screen_to_alpha(img_path, out_path):
    img = Image.open(img_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    for item in datas:
        r, g, b, a = item
        # Calculate max intensity
        max_c = max(r, g, b)
        if max_c == 0:
            new_data.append((0, 0, 0, 0))
        else:
            # Unpremultiply colors
            new_r = int(min(255, (r * 255) / max_c))
            new_g = int(min(255, (g * 255) / max_c))
            new_b = int(min(255, (b * 255) / max_c))
            new_data.append((new_r, new_g, new_b, max_c))

    img.putdata(new_data)
    img.save(out_path, "PNG")

screen_to_alpha("./Shared/Assets.xcassets/AppIcon.appiconset/icon-1024.png", "./Shared/Assets.xcassets/CustomIcon.imageset/icon.png")
