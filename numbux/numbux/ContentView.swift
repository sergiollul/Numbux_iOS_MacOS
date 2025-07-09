//
//  ContentView.swift
//  numbux
//
//  Created by Sergio Sánchez on 8/7/25.
//

import SwiftUI

// Custom accent color from hex #FF6300
extension Color {
    static let accentOrange = Color(red: 1.0, green: 0.3882353, blue: 0.0)
}

// MARK: - Drawer Content
struct DrawerContent: View {
    @Binding var blockingEnabled: Bool
    @Binding var showDisablePinAlert: Bool
    @Binding var currentPage: Int
    let maxPage: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 14)

            Text("NumbuX")
                .font(.system(size: 28))
                .bold()
                .foregroundColor(.accentOrange)
                .padding(.vertical, 0)

            Toggle(isOn: $blockingEnabled) {
                Text("Modo Foco")
                    .foregroundColor(.white)
                    .font(.system(size: 22))
            }
            .toggleStyle(SwitchToggleStyle(tint: .accentOrange))
            .padding(.vertical, 24)
            .onChange(of: blockingEnabled) { newValue in
                if !newValue {
                    showDisablePinAlert = true
                }
            }

            Spacer()

            // Page title
            Text(pageTitle)
                .font(.system(size: 16))
                .foregroundColor(.accentOrange)
                .padding(.bottom, 2)

            // Page selector
            HStack(spacing: 24) {
                Button {
                    if currentPage > 1 { currentPage -= 1 }
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 46))
                        .foregroundColor(.accentOrange)
                }

                Text("\(currentPage)")
                    .font(.system(size: 32))
                    .foregroundColor(.white)

                Button {
                    if currentPage < maxPage { currentPage += 1 }
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 46))
                        .foregroundColor(.accentOrange)
                }
            }
            .padding(.bottom, 2)

            Text("Cambiar Herramienta")
                .font(.system(size: 10))
                .foregroundColor(.white)
                .padding(.bottom, 6)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentOrange.opacity(0.8), lineWidth: 2)
                )
        )
        .ignoresSafeArea(edges: .bottom)
    }

    private var pageTitle: String {
        switch currentPage {
        case 1: return "Calculadora"
        case 2: return "Científica"
        case 3: return "Diccionario"
        default: return ""
        }
    }
}

// MARK: - Custom App Bar
struct NumbuXAppBar: View {
    @Binding var isDrawerOpen: Bool
    let enabled: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { isDrawerOpen.toggle() } label: {
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
        }
        .accentColor(.white)
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var isDrawerOpen = false
    @State private var blockingEnabled = false
    @State private var showDisablePinAlert = false
    @State private var currentPage = 1
    private let maxPage = 3

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                NumbuXAppBar(isDrawerOpen: $isDrawerOpen, enabled: blockingEnabled)

                // Main content placeholder
                Spacer()

                BasicCalculatorView()
                    .padding()

                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(false)
        }
        .accentColor(.white)
        .sheet(isPresented: $isDrawerOpen) {
            DrawerContent(
                blockingEnabled: $blockingEnabled,
                showDisablePinAlert: $showDisablePinAlert,
                currentPage: $currentPage,
                maxPage: maxPage
            )
            .presentationDetents([.fraction(0.83)])
            .presentationDragIndicator(.visible)
        }
        .alert("Disable PIN?", isPresented: $showDisablePinAlert) {
            Button("Cancel", role: .cancel) { blockingEnabled = true }
            Button("OK") { blockingEnabled = false }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

