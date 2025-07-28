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
    @FocusState private var isFieldFocused: Bool
    @State private var showDisclaimer: Bool = true

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
                        .font(.system(size: 20))
                        .focused($isFieldFocused)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isFieldFocused ? Color.accentOrange : Color.gray.opacity(0.5),
                                        lineWidth: isFieldFocused ? 2 : 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFieldFocused)

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
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onAppear {
                    observeKeyboard()
                }
                // cuando showDisclaimer sea true,
                // difumina y deshabilita la interacción
                .blur(radius: showDisclaimer ? 3 : 0)
                .disabled(showDisclaimer)
            // fullScreenCover para el disclaimer
            .fullScreenCover(isPresented: $showDisclaimer) {
                DisclaimerView(isPresented: $showDisclaimer)
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

/// El disclaimer que se muestra al inicio
struct DisclaimerView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // 1. Fondo negro en toda la pantalla
            Color.black
                .ignoresSafeArea()

            VStack {
                Spacer().frame(height: 40)

                VStack(spacing: 24) {
                    Text("Aviso Legal")
                        .font(.largeTitle)
                        .bold()

                    ScrollView {
                        Text("""
                        NumbuX NO guarda ningún tipo de dato del usuario. 
                        
                        Cualquier información que se requiere es con el objetivo de NO invadir el móvil del alumno fuera del centro educativo y horario lectivo.
                        
                        Puede leer nuestros términos y condiciones en: www.numbux.com
                        
                        Para más información, por favor, contáctenos a través de los medios habilitados en nuestra web: www.numbux.com
                        
                        
                        Gracias,
                        El equipo de NumbuX.
                        """)
                        .padding()
                    }

                    Button("De acuerdo") {
                        isPresented = false
                    }
                    .buttonStyle(AccentOrangeButtonStyle())
                    .padding(.bottom, 30)
                }
                .padding()
                .foregroundColor(.white)

                Spacer()
            }
        }
    }
}




// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
