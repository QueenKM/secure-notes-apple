import Foundation
import Observation
import SecureNotesCore

@MainActor
@Observable
final class AppContainer {
    let feature: NotesFeature

    init() {
        let directory = URL.applicationSupportDirectory.appending(path: "SecureNotes", directoryHint: .isDirectory)
        let file = directory.appending(path: "vault.json")
        feature = NotesFeature(store: FileBackedSecureNotesStore(fileURL: file))
    }
}
