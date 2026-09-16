import Foundation
let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget"
if let ud = UserDefaults(suiteName: path) {
    if let data = ud.data(forKey: "releaseStats_obsproject_obs-studio") {
        print("Data size: \(data.count) bytes")
    }
}
