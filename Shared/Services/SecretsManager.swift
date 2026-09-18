//
//  SecretsManager.swift
//  GitCounter
//
//  Copyright © 2026 Black Pinion LLC. All rights reserved.
//

import Foundation

class SecretsManager {
    static let shared = SecretsManager()
    
    private let fileName = "pat_store.json"
    
    private init() {}
    
    private func getDocumentsDirectory() -> URL {
        if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        } else {
            let path = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents"
            return URL(fileURLWithPath: path)
        }
    }
    
    func getPAT() -> String {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: url)
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
               let pat = dict["pat"] {
                return pat
            }
        } catch {
            // File might not exist yet, or other error
        }
        return ""
    }
    
    func savePAT(_ pat: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        let dict = ["pat": pat]
        do {
            let dir = getDocumentsDirectory()
            if !FileManager.default.fileExists(atPath: dir.path) {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            try data.write(to: url)
        } catch {
            print("Failed to save PAT: \(error)")
        }
    }
    
    func clearPAT() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Failed to clear PAT: \(error)")
        }
    }
}
