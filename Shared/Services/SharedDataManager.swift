import Foundation
import Combine

class SharedPreferences: ObservableObject {
    static let shared = SharedPreferences()
    
    @Published var savedOwner: String = "" {
        didSet { save() }
    }
    @Published var savedRepo: String = "" {
        didSet { save() }
    }
    
    @Published var unauthorizedTrafficRepos: [String: Date] = [:] {
        didSet { save() }
    }
    
    private let defaults = UserDefaults(suiteName: "group.io.githubcounter") ?? UserDefaults.standard
    
    private init() {
        load()
    }
    
    func load() {
        if let owner = defaults.string(forKey: "savedOwner") {
            self.savedOwner = owner
        }
        if let repo = defaults.string(forKey: "savedRepo") {
            self.savedRepo = repo
        }
        if let data = defaults.data(forKey: "unauthorizedTrafficRepos"),
           let dict = try? JSONDecoder().decode([String: Date].self, from: data) {
            self.unauthorizedTrafficRepos = dict
        }
    }
    
    private func save() {
        defaults.set(savedOwner, forKey: "savedOwner")
        defaults.set(savedRepo, forKey: "savedRepo")
        if let data = try? JSONEncoder().encode(unauthorizedTrafficRepos) {
            defaults.set(data, forKey: "unauthorizedTrafficRepos")
        }
    }
    
    func markTrafficUnauthorized(for repoIdentifier: String) {
        unauthorizedTrafficRepos[repoIdentifier] = Date()
    }
    
    func isTrafficUnauthorized(for repoIdentifier: String) -> Bool {
        if let lastAttempt = unauthorizedTrafficRepos[repoIdentifier] {
            // Check if it has been less than 24 hours (86400 seconds)
            return Date().timeIntervalSince(lastAttempt) < 86400
        }
        return false
    }
}
