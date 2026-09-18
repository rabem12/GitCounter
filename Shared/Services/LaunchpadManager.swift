//
//  LaunchpadManager.swift
//  GitCounter
//
//  Copyright © 2026 Black Pinion LLC. All rights reserved.
//

import Foundation

class LaunchpadManager: ObservableObject {
    @Published var savedRepos: [String] = []
    
    private let storageKey = "launchpad_saved_repos"
    
    init() {
        load()
    }
    
    func load() {
        savedRepos = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
    }
    
    func save() {
        UserDefaults.standard.set(savedRepos, forKey: storageKey)
    }
    
    func addRepo(owner: String, repo: String) {
        let trimmedOwner = owner.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedRepo = repo.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedOwner.isEmpty && !trimmedRepo.isEmpty else { return }
        
        let identifier = "\(trimmedOwner)/\(trimmedRepo)"
        if !savedRepos.contains(identifier) {
            savedRepos.append(identifier)
            save()
        }
    }
    
    func removeRepo(at offsets: IndexSet) {
        savedRepos.remove(atOffsets: offsets)
        save()
    }
    
    func removeRepo(_ identifier: String) {
        if let index = savedRepos.firstIndex(of: identifier) {
            savedRepos.remove(at: index)
            save()
        }
    }
}
