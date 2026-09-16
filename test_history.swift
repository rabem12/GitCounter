import Foundation

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
print("Path: \(path)")
if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
    print("Found dictionary with \(dict.keys.count) keys")
    var result: [(String, String)] = []
    for key in dict.keys where key.hasPrefix("history_snapshots_") {
        let parts = key.replacingOccurrences(of: "history_snapshots_", with: "").split(separator: "_", maxSplits: 1)
        if parts.count == 2 {
            result.append((String(parts[0]), String(parts[1])))
        }
    }
    print("Repos: \(result)")
} else {
    print("Failed to load dictionary from plist.")
}
