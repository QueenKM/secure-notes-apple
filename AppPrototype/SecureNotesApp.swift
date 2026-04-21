import SwiftUI

@main
struct SecureNotesApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            NotesHomeView(feature: container.feature)
                .environment(container)
        }
    }
}
