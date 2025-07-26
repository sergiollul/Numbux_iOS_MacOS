import SwiftUI

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
        NavigationStack {
            // Main scrollable content
            ScrollView {
                VStack(spacing: 16) {
                    // Master ON/OFF buttons
                    HStack(spacing: 16) {
                        Button("Desactivar") {
                            remoteEnabled = false
                            dummyStates = Array(repeating: false, count: dummyStates.count)
                        }
                        .buttonStyle(.bordered)

                        Button("Activar") {
                            remoteEnabled = true
                            dummyStates = Array(repeating: true, count: dummyStates.count)
                        }
                        .buttonStyle(.borderedProminent)
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
                    .padding(.horizontal)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showDialog = true
                    }

                    // PIN AlertDialog
                    if showDialog {
                        // Use a separate view modifier or custom overlay
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
                        ForEach(dummyStates.indices, id: \ .self) { index in
                            HStack {
                                Text("Alumno - ES12\(index + 13)")
                                Spacer()
                                Toggle("", isOn: $dummyStates[index])
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(24)
            }
            // Navigation bar header matching Compose topAppBar
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
                // Make navigation bar transparent
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
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
