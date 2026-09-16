import Foundation

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents/tcc_app_test.json"
let resultPath = "/tmp/tcc_app_result.txt"

do {
    let dir = (path as NSString).deletingLastPathComponent
    try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
    try "{\"test\": true}".write(toFile: path, atomically: true, encoding: .utf8)
    let str = try String(contentsOfFile: path)
    try "SUCCESS: \(str)".write(toFile: resultPath, atomically: true, encoding: .utf8)
} catch {
    try "ERROR: \(error)".write(toFile: resultPath, atomically: true, encoding: .utf8)
}
