import Cocoa

let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let directoryURL = scriptURL.appendingPathComponent("Shared/Assets.xcassets/AppIcon.appiconset")

guard let files = try? FileManager.default.contentsOfDirectory(atPath: directoryURL.path) else {
    print("Failed to read directory: \(directoryURL.path)")
    exit(1)
}

for file in files where file.hasSuffix(".png") {
    let url = URL(fileURLWithPath: directoryPath).appendingPathComponent(file)
    guard let image = NSImage(contentsOf: url),
          let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Failed to read \(file)")
        continue
    }
    
    // Create a new bitmap context with alpha
    let width = cgImage.width
    let height = cgImage.height
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
        print("Failed to create context for \(file)")
        continue
    }
    
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    guard let newCgImage = context.makeImage() else {
        print("Failed to create new cgImage for \(file)")
        continue
    }
    
    let newRep = NSBitmapImageRep(cgImage: newCgImage)
    guard let pngData = newRep.representation(using: .png, properties: [:]) else {
        print("Failed to generate png data for \(file)")
        continue
    }
    
    do {
        try pngData.write(to: url)
        print("Converted \(file) to include alpha channel")
    } catch {
        print("Failed to save \(file)")
    }
}
