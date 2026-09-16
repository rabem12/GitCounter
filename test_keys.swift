import Foundation

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget"
guard let ud = UserDefaults(suiteName: path) else {
    print("Could not load UserDefaults at path: \(path)")
    exit(1)
}

let dict = ud.dictionaryRepresentation()
print("Total keys: \(dict.keys.count)")
for key in dict.keys {
    if key.hasPrefix("history_snapshots_") || key.hasPrefix("releaseStats_") || key.hasPrefix("Cache_") {
        print("Found key: \(key)")
    }
}
