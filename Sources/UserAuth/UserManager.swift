#if canImport(Combine)
import Foundation
import Combine
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

public class UserManager: NSObject, ObservableObject {
    @Published public private(set) var currentUser: User?
    private static let userKey = "CurrentUser"

    public override init() {
        super.init()
        if let data = UserDefaults.standard.data(forKey: Self.userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }

    public func signInLocally(name: String) {
        currentUser = User(name: name)
        persistCurrentUser()
    }

#if canImport(AuthenticationServices)
    public func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
#endif

    public func signOut() {
        currentUser = nil
        persistCurrentUser()
    }

    private func persistCurrentUser() {
        if let user = currentUser, let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: Self.userKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.userKey)
        }
    }
}

#if canImport(AuthenticationServices)
extension UserManager: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            currentUser = User(id: credential.user, name: fullName)
            persistCurrentUser()
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization error: \(error)")
    }
}
#endif

#else
import Foundation

public class UserManager: NSObject {
    public private(set) var currentUser: User?
    private static let userKey = "CurrentUser"

    public override init() {
        super.init()
        if let data = UserDefaults.standard.data(forKey: Self.userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }

    public func signInLocally(name: String) {
        currentUser = User(name: name)
        persistCurrentUser()
    }

    public func signOut() {
        currentUser = nil
        persistCurrentUser()
    }

    private func persistCurrentUser() {
        if let user = currentUser, let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: Self.userKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.userKey)
        }
    }
}
#endif
