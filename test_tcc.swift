import Foundation

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents/test.txt"
do {
    try "test".write(toFile: path, atomically: true, encoding: .utf8)
    print("Write to Documents success")
} catch {
    print("Write Error: \(error)")
}
