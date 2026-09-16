import Foundation

let domain = "io.githubcounter.GithubCounterApp.Widget" as CFString
CFPreferencesAppSynchronize(domain)
if let val = CFPreferencesCopyMultiple(nil, domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? [String: Any] {
    print("CFPreferences keys count: \(val.keys.count)")
} else {
    print("CFPreferences failed")
}
