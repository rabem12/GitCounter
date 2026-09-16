import SwiftUI

@main
struct GithubCounterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 500)
                .onOpenURL { url in
                    if AppDelegate.isContentViewReady {
                        AppDelegate.processDeepLink(url)
                    } else {
                        AppDelegate.pendingWidgetURL = url
                    }
                }
        }
    }
}
