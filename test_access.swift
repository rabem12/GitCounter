import Foundation

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
if FileManager.default.isReadableFile(atPath: path) {
    print("Readable!")
} else {
    print("NOT Readable!")
}
