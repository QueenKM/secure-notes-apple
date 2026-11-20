import SwiftUI

@main
struct SecureNotesApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            NotesHomeView(feature: container.feature)
                .environment(container)
                .privacySensitive()
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background { container.feature.lock() }
                }
        }
    }
}
