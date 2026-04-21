import Foundation
import Observation
import SecureNotesCore

@MainActor
@Observable
final class AppContainer {
    let feature = NotesFeature()
    let cryptoService = NoteCryptoService()
    let store = InMemorySecureNotesStore()
}
