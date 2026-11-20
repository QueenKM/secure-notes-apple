import SwiftUI

struct UnlockGateView: View {
    let feature: NotesFeature

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 44))
                .foregroundStyle(.teal)

            Text("Secure Notes")
                .font(.largeTitle.weight(.bold))

            Text("Use Face ID, Touch ID, or your device passcode to unlock encrypted notes.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 420)

            Button("Unlock") {
                Task { await feature.unlock() }
            }
            .disabled(feature.isBusy)
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}
