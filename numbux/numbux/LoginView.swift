import SwiftUI
import UserNotifications

/// A SwiftUI view that replicates the Android-style login activity logic.
struct LoginView: View {
    @AppStorage("role") private var role: String?
    @State private var credential: String = ""
    @State private var error: String? = nil
    @State private var showPermissionDialog: Bool = false // Only show after successful student login
    @State private var navigateToControl: Bool = false
    @State private var navigateToMain: Bool = false
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Introduce tu usuario")
                    .font(.headline)

                TextField("Clave de acceso", text: $credential)
                    .textFieldStyle(.roundedBorder)

                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button("Entrar") {
                    handleLogin()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding(24)
            .padding(.bottom, keyboardHeight)
            .onAppear {
                observeKeyboard()
            }
            // Navigate after login validation and permission flow
            .navigationDestination(isPresented: $navigateToControl) {
                ControlView()
            }
            .navigationDestination(isPresented: $navigateToMain) {
                ContentView()    // Navigate to your main calculator view
            }
            // Alert for notification permission, triggered only for students
            .alert("Permitir notificaciones?", isPresented: $showPermissionDialog) {
                Button("Entendido") {
                    UserDefaults.standard.set(true, forKey: "notif_dialog_shown")
                    requestNotificationPermission()
                }
            } message: {
                Text("Necesitamos permiso de notificaciones para ofrecer accesibilidad completa.")
            }
        }
    }

    // MARK: - Login Logic

    private func handleLogin() {
        let trimmed = credential.trimmingCharacters(in: .whitespacesAndNewlines)
        switch trimmed {
        case "profesor1234":
            role = "controller"
            navigateToControl = true
        case "Estudiante1234":
            role = "student"
            checkNotificationPermission() // Trigger permission flow only on valid student login
        default:
            error = "Credenciales incorrectas"
        }
    }

    // MARK: - Notification Permissions

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // Show custom dialog once before requesting system prompt
                    if !UserDefaults.standard.bool(forKey: "notif_dialog_shown") {
                        showPermissionDialog = true
                    } else {
                        requestNotificationPermission()
                    }
                default:
                    // Already granted or denied – proceed to main view
                    navigateToMain = true
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            DispatchQueue.main.async {
                navigateToMain = true
            }
        }
    }

    // MARK: - Keyboard Observer

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.3)) {
                    keyboardHeight = frame.height
                }
            }
        }
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeIn(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
    }
}

// MARK: - Placeholder ControlView

struct ControlView: View {
    var body: some View {
        Text("🔧 Control Panel")
            .font(.largeTitle)
            .padding()
            .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
