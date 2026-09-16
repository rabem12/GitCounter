import Foundation

let ud = UserDefaults(suiteName: "io.githubcounter.GithubCounterApp.Widget")
let dict = ud?.dictionaryRepresentation()
print("Domain keys count: \(dict?.keys.count ?? 0)")
