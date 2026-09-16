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
    
    private let defaults = UserDefaults.standard
    
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
    }
    
    private func save() {
        defaults.set(savedOwner, forKey: "savedOwner")
        defaults.set(savedRepo, forKey: "savedRepo")
    }
}
