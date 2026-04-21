import SwiftUI
import SecureNotesCore

struct NoteRowView: View {
    let note: SecureNote
    let onOpen: () -> Void
    let onTogglePin: () -> Void
    let onArchive: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(note.title)
                            .font(.headline)
                        if note.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundStyle(.teal)
                        }
                    }
                    Text(note.body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    if !note.tags.isEmpty {
                        Text(note.tags.joined(separator: " · "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            HStack {
                Button(note.isPinned ? "Unpin" : "Pin", action: onTogglePin)
                Button("Archive", action: onArchive)
            }
            .buttonStyle(.borderless)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
