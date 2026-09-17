import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // AppDelegate is now significantly simplified as deep linking is handled
    // via a physical file handoff system directly in ContentView.
}

extension Notification.Name {
    static let didReceiveDeepLink = Notification.Name("didReceiveDeepLink")
}
