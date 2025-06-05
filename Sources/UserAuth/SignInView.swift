#if canImport(SwiftUI)
import SwiftUI
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

public struct SignInView: View {
    @ObservedObject private var manager: UserManager
    @State private var name: String = ""

    public init(manager: UserManager) {
        self.manager = manager
    }

    public var body: some View {
        VStack {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding()
            Button("Sign In") {
                manager.signInLocally(name: name)
            }
#if canImport(AuthenticationServices)
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName]
            } onCompletion: { _ in
                manager.signInWithApple()
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 44)
#endif
        }
    }
}
#endif
