import Foundation

class DiagnosticsManager: ObservableObject {
    static let shared = DiagnosticsManager()
    
    @Published var lastOpenedURL: String = "None"
    @Published var mainAppDirectory: String = ""
    @Published var widgetDirectory: String = ""
    @Published var filesInSharedDirectory: [String] = []
    @Published var fileContents: [String: String] = [:]
    
    private init() {
        refresh()
    }
    
    func logOpenedURL(_ url: URL) {
        DispatchQueue.main.async {
            self.lastOpenedURL = url.absoluteString
        }
    }
    
    func log(_ message: String) {
        DispatchQueue.main.async {
            self.lastOpenedURL = message
        }
    }
    
    func refresh() {
        let home = NSHomeDirectory()
        let bundleId = Bundle.main.bundleIdentifier ?? "unknown"
        
        mainAppDirectory = "Home: \(home)\nBundleID: \(bundleId)"
        
        let documentsPath = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents"
        widgetDirectory = "Widget Documents: \(documentsPath)"
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsPath)
            filesInSharedDirectory = files.filter { $0.hasSuffix(".json") }
            
            fileContents.removeAll()
            for file in filesInSharedDirectory {
                let path = documentsPath + "/" + file
                if let attr = try? FileManager.default.attributesOfItem(atPath: path),
                   let size = attr[.size] as? Int64 {
                    fileContents[file] = "\(size) bytes"
                }
            }
            
            // Check legacy plist
            let plistPath = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
            if let dict = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                let historyKeys = dict.keys.filter { $0.hasPrefix("history_snapshots_") }
                let cacheKeys = dict.keys.filter { $0.hasPrefix("releaseStats_") }
                fileContents["Legacy Plist (io.githubcounter.GithubCounterApp.Widget)"] = "History Keys: \(historyKeys.count), Cache Keys: \(cacheKeys.count)"
            } else {
                fileContents["Legacy Plist"] = "Not found or unreadable"
            }
        } catch {
            filesInSharedDirectory = ["Error reading Widget Documents: \(error.localizedDescription)"]
            fileContents.removeAll()
        }
    }
}
