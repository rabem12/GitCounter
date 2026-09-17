import SwiftUI

struct NotesView: View {
    @StateObject private var notesManager = NotesManager()
    @State private var activeTitle: String = ""
    @State private var activeContent: String = ""
    @State private var activeNoteId: UUID? = nil
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: - Left Pane: Note Navigator (~260px)
            VStack(spacing: 0) {
                // Header & Search
                VStack(spacing: 10) {
                    HStack {
                        Text("Notes")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: createNewNote) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(
                                    LinearGradient(colors: [.yellow.opacity(0.8), .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .help("Create New Note")
                    }
                    
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        
                        TextField("Search notes...", text: $notesManager.searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                        
                        if !notesManager.searchText.isEmpty {
                            Button(action: { notesManager.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
                .padding(14)
                
                Divider()
                
                // Note List
                if notesManager.filteredNotes.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "note.text")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary.opacity(0.6))
                        Text(notesManager.searchText.isEmpty ? "No Notes Yet" : "No Matching Notes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(notesManager.searchText.isEmpty ? "Click + to create your first note." : "Try a different search keyword.")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(notesManager.filteredNotes) { note in
                                NoteRowCard(
                                    note: note,
                                    isSelected: note.id == notesManager.selectedNoteId
                                )
                                .onTapGesture {
                                    selectNote(note)
                                }
                            }
                        }
                        .padding(10)
                    }
                }
            }
            .frame(width: 270)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
            
            Divider()
            
            // MARK: - Right Pane: Note Editor
            VStack(spacing: 0) {
                if let currentNote = notesManager.selectedNote {
                    // Editor Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            TextField("Title", text: $activeTitle)
                                .font(.system(size: 22, weight: .bold))
                                .textFieldStyle(.plain)
                                .onChange(of: activeTitle) { newTitle in
                                    if let id = activeNoteId {
                                        notesManager.updateNote(id: id, title: newTitle, content: activeContent)
                                    }
                                }
                            
                            Spacer()
                            
                            Button(action: { showDeleteConfirmation = true }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .padding(8)
                                    .background(Color.primary.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            .help("Delete Note")
                            .alert("Delete Note?", isPresented: $showDeleteConfirmation) {
                                Button("Delete", role: .destructive) {
                                    if let id = activeNoteId {
                                        notesManager.deleteNote(id: id)
                                        syncEditorWithSelection()
                                    }
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("Are you sure you want to delete '\(currentNote.title.isEmpty ? "New Note" : currentNote.title)'? This action cannot be undone.")
                            }
                        }
                        
                        Text("Last edited \(formattedDate(currentNote.updatedAt))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    
                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Editor Body (Developer Monospaced)
                    TextEditor(text: $activeContent)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                        .onChange(of: activeContent) { newContent in
                            if let id = activeNoteId {
                                notesManager.updateNote(id: id, title: activeTitle, content: newContent)
                            }
                        }
                } else {
                    // Empty Selection
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No Note Selected")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text("Select a note from the left sidebar or click + to create a new note.")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                        Button(action: createNewNote) {
                            Text("+ Create Note")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
            }
            .background(Color(NSColor.textBackgroundColor).opacity(0.3))
        }
        .onAppear {
            syncEditorWithSelection()
        }
        .onChange(of: notesManager.selectedNoteId) { _ in
            syncEditorWithSelection()
        }
    }
    
    private func createNewNote() {
        notesManager.createNote()
        syncEditorWithSelection()
    }
    
    private func selectNote(_ note: NoteItem) {
        notesManager.selectedNoteId = note.id
        syncEditorWithSelection()
    }
    
    private func syncEditorWithSelection() {
        if let note = notesManager.selectedNote {
            activeNoteId = note.id
            activeTitle = note.title
            activeContent = note.content
        } else {
            activeNoteId = nil
            activeTitle = ""
            activeContent = ""
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Note Row Card
struct NoteRowCard: View {
    let note: NoteItem
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.title.isEmpty ? "New Note" : note.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(shortDate(note.updatedAt))
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            
            Text(snippetText(note.content))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)
                .lineLimit(2)
                .lineSpacing(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            ZStack {
                if isSelected {
                    LinearGradient(colors: [.yellow.opacity(0.9), .orange.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .cornerRadius(8)
                } else {
                    Color.primary.opacity(0.04)
                        .cornerRadius(8)
                }
            }
        )
        .contentShape(Rectangle())
    }
    
    private func shortDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    private func snippetText(_ content: String) -> String {
        let lines = content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        if lines.isEmpty {
            return "No additional text"
        }
        return lines.prefix(2).joined(separator: "\n")
    }
}
