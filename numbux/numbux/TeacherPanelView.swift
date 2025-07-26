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
    @State private var dummyStates = Array(repeating: false, count: 15)
    
    var body: some View {
        ZStack {
            // 1) Fill the entire screen with black
            Color.black
                .ignoresSafeArea()
            
            // 2) Put your navigation & content on top
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
                        .padding(.vertical, 16)

                        // Original "Modo Foco" switch row
                        HStack {
                            Text("Sergio Sánchez - ES1212")
                            Spacer()
                            Toggle("", isOn: $remoteEnabled)
                                .labelsHidden()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showDialog = true
                        }

                        // PIN AlertDialog
                        if showDialog {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .overlay(
                                    VStack(spacing: 16) {
                                        Text("PIN para Sergio Sánchez:")
                                            .font(.headline)

                                        Text(showSecret ? secretText : String(repeating: "*", count: secretText.count))
                                            .font(.system(.body, design: .monospaced))

                                        HStack {
                                            Button("Cerrar") {
                                                showDialog = false
                                            }
                                            Spacer()
                                            Button(showSecret ? "Ocultar" : "Mostrar") {
                                                showSecret.toggle()
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.2)))
                                    .padding(40)
                                )
                        }

                        // Dummy student switch rows
                        VStack(spacing: 12) {
                            ForEach(dummyStates.indices, id: \.self) { index in
                                HStack {
                                    Text("Alumno - ES12\(index + 13)")
                                    Spacer()
                                    Toggle("", isOn: $dummyStates[index])
                                        .labelsHidden()
                                }
                                .padding(.horizontal)
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(24)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isDrawerOpen.toggle()
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(isDrawerOpen ? .accentOrange : .white)
                                .padding(.leading, 18)
                        }
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
                    // Make navigation bar transparent so the black shows through
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
            }
        }
    }
}

// MARK: - Preview

struct TeacherPanelView_Previews: PreviewProvider {
    static var previews: some View {
        TeacherPanelView()
            .preferredColorScheme(.dark)
    }
}
