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
            ZStack {
                // ◀︎ Black background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Introduce tu usuario")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))

                    TextField("Clave de acceso", text: $credential)
                        .textFieldStyle(.roundedBorder)

                    if let error = error {
                        Text(error)
                            .foregroundColor(.accentOrange)
                            .bold()
                    }

                    Button("Entrar") {
                        handleLogin()
                    }
                    .buttonStyle(AccentOrangeButtonStyle())
                }
                .padding(24)
                .padding(.bottom, keyboardHeight)
                .onAppear {
                    observeKeyboard()
                }
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

/// A button style whose normal state is an orange fill with black text,
/// and whose pressed state is a clear background with orange text.
struct AccentOrangeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // switch text color based on pressed state
            .foregroundColor(configuration.isPressed ? .accentOrange : .black)
            .font(.system(size: 18, weight: .semibold))
            .padding(.vertical, 12)
            .frame(width: UIScreen.main.bounds.width * 0.65)
            // switch background fill based on pressed state
            .background(
                Group {
                    if configuration.isPressed {
                        Color.clear
                    } else {
                        Color.accentOrange
                    }
                }
            )
            .cornerRadius(8)
            // subtle scale feedback
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}


// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
