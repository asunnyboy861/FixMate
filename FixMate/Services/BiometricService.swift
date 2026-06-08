import Foundation
import LocalAuthentication

struct BiometricService {
    static var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    static var biometricType: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "None"
        }
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "None"
        }
    }

    static func authenticate() async -> Bool {
        let context = LAContext()
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock FixMate")
        } catch {
            return false
        }
    }
}
