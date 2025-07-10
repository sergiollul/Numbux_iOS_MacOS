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
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 14)

            Text("NumbuX")
                .font(.system(size: 32))
                .bold()
                .foregroundColor(.accentOrange)
                .padding(.top, 38)
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

            // ← Aquí el cambio: primero el label
            VStack(alignment: .leading, spacing: 0) {
                Text("Modo Foco:")
                    .foregroundColor(.white)
                    .font(.system(size: 23))
                    .padding(.top, 20)
                    .padding(.leading, 12)

                // luego en una línea aparte el toggle + estado
                HStack(alignment: .center, spacing: 12) {
                    Toggle("", isOn: $blockingEnabled)
                        .labelsHidden()
                        .toggleStyle(OrangeBorderToggleStyle())
                        .frame(width: 42, height: 24)    // same size as your style
                        .fixedSize()                     // guard against unexpected stretching

                    Text(blockingEnabled ? "Activado" : "Desactivado")
                        .foregroundColor(.white)
                        .font(.system(size: 19))
                        .frame(height: 24)              // match the toggle’s height
                        .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 9)
                .padding(.top, 10)
            }

            Spacer()

            // resto de tu contenido…
            Text(pageTitle)
                .font(.system(size: 22))
                .foregroundColor(.accentOrange)
                .padding(.bottom, 7)
                .bold()

            HStack(spacing: 20) {
                Button { if currentPage > 1 { currentPage -= 1 } } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.accentOrange)
                }
                Text("\(currentPage)")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                Button { if currentPage < maxPage { currentPage += 1 } } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.accentOrange)
                }
            }
            .padding(.bottom, 2)

            Text("Cambiar Herramienta")
                .font(.system(size: 15))
                .foregroundColor(.white)

            Spacer()
        }
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accentOrange.opacity(0.8), lineWidth: 2)
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

/// Toggle con borde naranja, fondo negro y círculo naranja cuando está OFF
struct OrangeBorderToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()

            ZStack {
                // the capsule – orange when on, black when off
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isOn ? Color.accentOrange : Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentOrange, lineWidth: 2)
                            .opacity(configuration.isOn ? 0 : 1)
                    )

                // the knob – black when on, orange when off
                Circle()
                        .fill(configuration.isOn ? Color.black : Color.accentOrange)
                        .frame(width: 20, height: 20)
                        // 42/2 = 21; 21 − (20/2) = 11; minus 2pt padding → 9
                        .offset(x: configuration.isOn ?  9 : -9)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                }
                .frame(width: 42, height: 24)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}


// Tamaños de ejemplo; cámbialos a tu gusto
private let Fifty: CGFloat = 50
private let thirty: CGFloat = 30


// MARK: - Main Content View
struct ContentView: View {
    @State private var isDrawerOpen       = false
    @State private var dragOffset: CGFloat = 0
    @State private var blockingEnabled    = false
    @State private var showDisablePinAlert = false
    @State private var currentPage        = 1
    private let maxPage                  = 3

    var body: some View {
        ZStack(alignment: .leading) {
            // ─── Main App ─────────────────────────────────
            NavigationView {
                VStack(spacing: 0) {
                    NumbuXAppBar(isDrawerOpen: $isDrawerOpen, enabled: blockingEnabled)
                    Spacer()
                    BasicCalculatorView().padding()
                    Spacer()
                }
                .background(Color.black.ignoresSafeArea())
                .navigationBarHidden(false)
            }
            .accentColor(.white)

            // ─── Scrim + Drawer ───────────────────────────
            if isDrawerOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { closeDrawer() } }

                GeometryReader { geo in
                    let w = geo.size.width * 0.7
                    let h = geo.size.height * 0.8

                    HStack(spacing: 0) {
                        DrawerContent(
                            blockingEnabled: $blockingEnabled,
                            showDisablePinAlert: $showDisablePinAlert,
                            currentPage: $currentPage,
                            maxPage: maxPage
                        )
                        .frame(width: w, height: h)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentOrange.opacity(0.8), lineWidth: 2)
                        )
                        // → posición base + desplazamiento de gesto
                        .offset(x: -w + (isDrawerOpen ? w : 0) + dragOffset)
                        Spacer()
                    }
                }
                .ignoresSafeArea()
            }
        }
        // ─── Gesto global de abrir/cerrar ───────────────
        .highPriorityGesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .global)
                .onChanged { v in
                    // si está abierto y arrastramos a la izquierda, movemos el panel
                    if isDrawerOpen && v.translation.width < 0 {
                        dragOffset = v.translation.width
                    }
                }
                .onEnded { v in
                    let openThreshold  = 100.0
                    let closeThreshold = -100.0

                    if !isDrawerOpen {
                        // start from very left edge & swipe right → abrir
                        if v.startLocation.x < 30 && v.translation.width > openThreshold {
                            withAnimation(.easeInOut) {
                                isDrawerOpen = true
                                dragOffset = 0
                            }
                        }
                    } else {
                        // swipe left enough → cerrar
                        if v.translation.width < closeThreshold {
                            withAnimation(.easeInOut) { closeDrawer() }
                        } else {
                            // si no llega al umbral, retrocede
                            withAnimation(.easeInOut) { dragOffset = 0 }
                        }
                    }
                }
        )
        .alert("Disable PIN?", isPresented: $showDisablePinAlert) {
            Button("Cancel", role: .cancel) { blockingEnabled = true }
            Button("OK")               { blockingEnabled = false }
        }
    }

    private func closeDrawer() {
        isDrawerOpen = false
        dragOffset   = 0
    }
}


    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

