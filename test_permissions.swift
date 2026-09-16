import Foundation

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
print("File exists: \(FileManager.default.fileExists(atPath: path))")
print("Is readable: \(FileManager.default.isReadableFile(atPath: path))")
if let attr = try? FileManager.default.attributesOfItem(atPath: path) {
    print("Permissions: \(String(format: "%03O", attr[.posixPermissions] as? Int ?? 0))")
}
