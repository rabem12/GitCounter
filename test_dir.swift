import Foundation

let path = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents"
print("Path:", path)
do {
    let files = try FileManager.default.contentsOfDirectory(atPath: path)
    print("Files:", files)
} catch {
    print("Error:", error)
}
