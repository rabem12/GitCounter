from PIL import Image

def make_black_transparent(img_path, out_path):
    img = Image.open(img_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    for item in datas:
        # Change all dark pixels (near black) to transparent
        # R, G, B < 30 is considered black background here
        if item[0] < 30 and item[1] < 30 and item[2] < 30:
            # We can use the brightness as the alpha to have smooth edges!
            brightness = int(max(item[0], item[1], item[2]))
            new_data.append((item[0], item[1], item[2], brightness))
        else:
            # Not black, keep fully opaque
            new_data.append((item[0], item[1], item[2], 255))

    img.putdata(new_data)
    img.save(out_path, "PNG")

make_black_transparent("./Shared/Assets.xcassets/AppIcon.appiconset/icon-1024.png", "./Shared/Assets.xcassets/CustomIcon.imageset/icon.png")
