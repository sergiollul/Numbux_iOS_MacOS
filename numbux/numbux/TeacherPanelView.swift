import SwiftUI

struct AccentOrangeButtonStyle_teacher: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(configuration.isPressed ? .accentOrange : .black)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.clear : Color.accentOrange)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentOrange, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// A SwiftUI view for the Teacher Panel, matching the Android Compose layout.
struct TeacherPanelView: View {
    // Drawer state (if needed later)
    @State private var isDrawerOpen = false
    
    // Master toggle persisted in UserDefaults
    @AppStorage("blocking_enabled") private var remoteEnabled = false
    
    // PIN dialog state
    @State private var showDialog = false
    @State private var secretText = "1234"      // Example PIN
    @State private var showSecret = false
    
    // Dummy student toggles
    @State private var dummyStates = Array(repeating: false, count: 20)
    
    var body: some View {
        ZStack {
            // 1) Fill the entire screen with black
            Color.black
                .ignoresSafeArea()

            // 2) Your main navigation & content
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Master ON/OFF buttons
                        HStack(spacing: 16) {
                            Button("Desactivar") {
                                remoteEnabled = false
                                dummyStates = Array(repeating: false, count: dummyStates.count)
                            }
                            .buttonStyle(AccentOrangeButtonStyle_teacher())

                            Button("Activar") {
                                remoteEnabled = true
                                dummyStates = Array(repeating: true, count: dummyStates.count)
                            }
                            .buttonStyle(AccentOrangeButtonStyle_teacher())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                        // Original "Modo Foco" switch row
                        HStack {
                            Text("Sergio Sánchez - ES1212")
                                .layoutPriority(1)
                                .font(.system(size: 19))
                            Toggle("", isOn: $remoteEnabled)
                                .toggleStyle(OrangeBorderToggleStyle())
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showDialog = true
                        }

                        // Dummy student switch rows
                        VStack(spacing: 12) {
                            ForEach(dummyStates.indices, id: \.self) { index in
                                HStack {
                                    Text("Alumno - ES12\(index + 13)")
                                        .font(.system(size: 19))
                                    Toggle("", isOn: $dummyStates[index])
                                        .toggleStyle(OrangeBorderToggleStyle())
                                    Spacer()
                                }
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 0)
                    //.padding(24)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                            Text("Panel del Profesor")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                        }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image("logo_blanco_numbux")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.trailing, 6)
                    }
                }
                .accentColor(.white)
                .onAppear {
                    let appearance = UINavigationBarAppearance()
                    // Make it opaque:
                    appearance.configureWithOpaqueBackground()
                    // Give it a pure black fill
                    appearance.backgroundColor = UIColor.black
                    // Ensure title text (and our custom leading Text) stays white
                    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
            }

            // 3) Full‑screen PIN overlay above everything else
            if showDialog {
                // Dimmed backdrop
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)

                // Dialog box
                VStack(spacing: 16) {
                    Text("PIN para Sergio Sánchez:")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(showSecret ? secretText : String(repeating: "*", count: secretText.count))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)

                    HStack {
                        Button("Cerrar") {
                            showDialog = false
                        }.foregroundColor(.accentOrange)
                        Spacer()
                        Button(showSecret ? "Ocultar" : "Mostrar") {
                            showSecret.toggle()
                        }.foregroundColor(.accentOrange)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black))
                .padding(40)
                .transition(.scale)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showDialog)
    }
}

// MARK: - Preview

struct TeacherPanelView_Previews: PreviewProvider {
    static var previews: some View {
        TeacherPanelView()
            .preferredColorScheme(.dark)
    }
}
