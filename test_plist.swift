import Foundation

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
    print("Total keys from file: \(dict.keys.count)")
} else {
    print("Could not read plist")
}
