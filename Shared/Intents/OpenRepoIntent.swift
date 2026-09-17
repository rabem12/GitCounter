import AppIntents
import Foundation
import AppKit

struct OpenRepoIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Repository"
    
    // Set openAppWhenRun to true so the system automatically brings the app to the foreground
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Owner") var owner: String
    @Parameter(title: "Repo") var repo: String
    
    init() {}
    
    init(owner: String, repo: String) {
        self.owner = owner
        self.repo = repo
    }
    
    func perform() async throws -> some IntentResult {
        // 1. Determine flag file path (Widget's Documents directory)
        // Since we are running INSIDE the widget sandbox, we can just use FileManager.default.urls
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .result()
        }
        let flagURL = documentsURL.appendingPathComponent("clicked_flag.json")
        
        // 2. Aggressively delete any existing flag to avoid stale data (Flaw 3)
        try? FileManager.default.removeItem(at: flagURL)
        
        // 3. Write new flag atomically (Flaw 2)
        // Add a timestamp to prevent the app from reading it if the launch was delayed for minutes
        let payload = "{\"owner\":\"\(owner)\", \"repo\":\"\(repo)\", \"timestamp\": \(Date().timeIntervalSince1970)}"
        let data = payload.data(using: .utf8)
        
        // We write directly to the Documents directory of the widget sandbox.
        // Because of .atomic, this is un-interruptible and guaranteed to be physically on disk before moving on.
        try? data?.write(to: flagURL, options: .atomic)
        
        // 4. Force launch the main app
        // We use openAppWhenRun = true instead of NSWorkspace (which is forbidden in widgets).
        // The system will bring the app to the foreground, which triggers onAppear / onReceive
        // where the app will catch the flag file we just wrote.
        
        return .result()
    }
}
