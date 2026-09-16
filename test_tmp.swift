import Foundation
let path = "/tmp/githubcounter_test.txt"
do {
    try "test".write(toFile: path, atomically: true, encoding: .utf8)
    print("Write to /tmp success")
    let str = try String(contentsOfFile: path)
    print("Read from /tmp success: \(str)")
} catch {
    print("Error: \(error)")
}
