import SwiftUI
import UserNotifications

/// A SwiftUI view that replicates the Android-style login activity logic.
struct LoginView: View {
    @AppStorage("role") private var role: String?
    @State private var credential: String = ""
    @State private var error: String? = nil
    @State private var showPermissionDialog: Bool = false
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
                TeacherPanelView()
                    .navigationBarBackButtonHidden(true)
                    .disableBackSwipe()
            }
            .navigationDestination(isPresented: $navigateToMain) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
                    .disableBackSwipe()
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
        switch trimmed.lowercased() {
        case "profesor1234":
            error = nil
            role = "controller"
            navigateToControl = true
        case "estudiante1234":
            error = nil
            role = "student"
            checkNotificationPermission()
        default:
            error = "Credenciales incorrectas"
        }
    }

    // MARK: - Notification Permissions

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    if !UserDefaults.standard.bool(forKey: "notif_dialog_shown") {
                        showPermissionDialog = true
                    } else {
                        requestNotificationPermission()
                    }
                } else {
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

// MARK: - Back Swipe Disabler

extension View {
    /// Hides the back button and disables the interactive swipe-back gesture
    func disableBackSwipe() -> some View {
        modifier(DisableBackSwipe())
    }
}

struct DisableBackSwipe: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DisableBackSwipeHelper())
    }
}

private struct DisableBackSwipeHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// Note: ControlView placeholder removed. Use TeacherPanelView.swift for controller role.

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
