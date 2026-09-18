//
//  NotesManager.swift
//  GitCounter
//
//  Copyright © 2026 Black Pinion LLC. All rights reserved.
//

import Foundation

struct NoteItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var updatedAt: Date
}

class NotesManager: ObservableObject {
    @Published var notes: [NoteItem] = []
    @Published var selectedNoteId: UUID? = nil
    @Published var searchText: String = ""
    
    private let storageKey = "github_counter_user_notes"
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                let decoded = try JSONDecoder().decode([NoteItem].self, from: data)
                self.notes = decoded.sorted { $0.updatedAt > $1.updatedAt }
                if self.selectedNoteId == nil, let first = self.notes.first {
                    self.selectedNoteId = first.id
                }
            } catch {
                print("Failed to decode notes: \(error)")
                setupStarterNoteIfNeeded()
            }
        } else {
            setupStarterNoteIfNeeded()
        }
    }
    
    func save() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    private func setupStarterNoteIfNeeded() {
        guard notes.isEmpty else { return }
        
        let starterContent = """
# Release Checklist & Quick Notes

Welcome to your developer scratchpad! Use this space for tokens, release reminders, commands, and checklists.

## Release Checklist
[ ] Bump build & version number in Xcode
[ ] Commit changes and push to origin/main
[ ] Tag release in Git (e.g., git tag v1.1.0 && git push --tags)
[ ] Draft GitHub Release notes with changelog
[ ] Verify GitHub PAT expiration date

## Helpful Snippets
- Build CLI: `xcodebuild -scheme GithubCounter -configuration Debug build`
- PAT scopes required: `repo`, `read:packages`
"""
        let starterNote = NoteItem(
            id: UUID(),
            title: "Release Checklist & Quick Notes",
            content: starterContent,
            updatedAt: Date()
        )
        notes = [starterNote]
        selectedNoteId = starterNote.id
        save()
    }
    
    func createNote() {
        let newNote = NoteItem(
            id: UUID(),
            title: "New Note",
            content: "",
            updatedAt: Date()
        )
        notes.insert(newNote, at: 0)
        selectedNoteId = newNote.id
        save()
    }
    
    func updateNote(id: UUID, title: String, content: String) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        
        // Only update if something actually changed
        if notes[index].title != title || notes[index].content != content {
            notes[index].title = title
            notes[index].content = content
            notes[index].updatedAt = Date()
            
            // Re-sort with most recently updated at top
            notes.sort { $0.updatedAt > $1.updatedAt }
            save()
        }
    }
    
    func deleteNote(id: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        notes.remove(at: index)
        
        if selectedNoteId == id {
            selectedNoteId = notes.first?.id
        }
        save()
    }
    
    var filteredNotes: [NoteItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return notes
        }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(query) ||
            note.content.localizedCaseInsensitiveContains(query)
        }
    }
    
    var selectedNote: NoteItem? {
        if let id = selectedNoteId, let note = notes.first(where: { $0.id == id }) {
            return note
        }
        return notes.first
    }
}
