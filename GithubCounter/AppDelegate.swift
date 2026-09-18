//
//  AppDelegate.swift
//  GitCounter
//
//  Copyright © 2026 Black Pinion LLC. All rights reserved.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            DeepLinkHandler.handle(url, source: "AppDelegate")
        }
    }
}

