# Architecture Notes

## Product Goal

Build a local-first secure notes app that feels polished enough for portfolio review and grounded enough to support real security discussions.

## Starter Split

The project is intentionally divided into two layers:

1. `SecureNotesCore`
2. `AppPrototype`

### SecureNotesCore

This is the part that should stay portable and testable:

- note models
- encryption service
- storage abstractions
- file-backed encrypted persistence

### AppPrototype

This is the SwiftUI shell that demonstrates:

- app flow
- unlock gate
- note list and editor interactions
- dependency wiring direction

## Recommended Next Build Order

1. Generate a real Xcode app target around `SecureNotesCore`
2. Replace in-memory storage with file-backed encrypted persistence
3. Add Keychain-backed key material storage
4. Add biometric unlock and inactivity lock
5. Add note search, archive, and export flows
