import Foundation
let urlStr = "githubcounter://trends?owner=obsproject&repo=obs-studio"
let url = URL(string: urlStr)!
let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
print("Scheme: \(url.scheme ?? "")")
print("Host: \(url.host ?? "")")
for item in components?.queryItems ?? [] {
    print("\(item.name) = \(item.value ?? "")")
}
