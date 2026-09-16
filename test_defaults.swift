import Foundation

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget"
print("Path: \(path)")
if let ud = UserDefaults(suiteName: path) {
    if let dict = ud.dictionaryRepresentation() as? [String: Any] {
        let keys = dict.keys.filter { $0.hasPrefix("history_") }
        print("Found history keys: \(keys)")
        if let firstKey = keys.first {
            let data = ud.data(forKey: firstKey)
            print("Data for \(firstKey): \(data?.count ?? 0) bytes")
        }
    } else {
        print("Failed to get dictionaryRepresentation")
    }
} else {
    print("Failed to load UserDefaults at suiteName")
}
