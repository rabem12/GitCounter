import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static var pendingWidgetURL: URL?
    static var isContentViewReady: Bool = false
    
    // We remove the NSAppleEventManager intercept so we don't steal the event from SwiftUI.
    // SwiftUI needs the event to know it should open the main WindowGroup on a cold start!
    
    static func processDeepLink(_ url: URL) {
        DiagnosticsManager.shared.logOpenedURL(url)
        
        guard url.scheme == "githubcounter", url.host == "trends" else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let queryItems = components?.queryItems else { return }
        
        var newOwner: String?
        var newRepo: String?
        
        for item in queryItems {
            if item.name == "owner" {
                newOwner = item.value
            } else if item.name == "repo" {
                newRepo = item.value
            }
        }
        
        if let owner = newOwner, let repo = newRepo {
            SharedPreferences.shared.savedOwner = owner
            SharedPreferences.shared.savedRepo = repo
            NotificationCenter.default.post(name: .didReceiveDeepLink, object: url)
        }
    }
}

extension Notification.Name {
    static let didReceiveDeepLink = Notification.Name("didReceiveDeepLink")
}
