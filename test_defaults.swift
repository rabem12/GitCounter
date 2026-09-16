import Foundation

let suiteName = "io.githubcounter.GithubCounterApp.Widget"
let key = "history_snapshots_test_test"

if let defaults = UserDefaults(suiteName: suiteName) {
    defaults.set("hello", forKey: key)
    print("Set value in \(suiteName)")
}
