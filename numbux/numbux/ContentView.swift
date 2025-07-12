//
//  ContentView.swift
//  numbux
//
//  Created by Sergio Sánchez on 8/7/25.
//

import SwiftUI
import Combine

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
                .padding(.leading, 15)
                .frame(maxWidth: .infinity, alignment: .leading)

            // ← Aquí el cambio: primero el label
            VStack(alignment: .leading, spacing: 0) {
                Text("Modo Foco:")
                    .foregroundColor(.white)
                    .font(.system(size: 23))
                    .padding(.top, 20)
                    .padding(.leading, 19)

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
                .padding(.leading, 16)
                .padding(.top, 10)
            }

            Spacer()

            // ——— bottom center group ———
            VStack(spacing: 8) {
                // 1) Page title
                Text(pageTitle)
                    .font(.system(size: 22))
                    .foregroundColor(.accentOrange)
                    .bold()

                // 2) Page controls
                HStack(spacing: 20) {
                    Button {
                        if currentPage > 1 { currentPage -= 1 }
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.accentOrange)
                    }

                    Text("\(currentPage)")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Button {
                        if currentPage < maxPage { currentPage += 1 }
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.accentOrange)
                    }
                }

                // 3) “Cambiar Herramienta”
                Text("Cambiar Herramienta")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)       // fill horizontally
            .multilineTextAlignment(.center)  // center all text inside
            .padding(.bottom, 16)             // some breathing room from bottom

        }
        .background(Color.black.opacity(0.7))
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
            // No more full-screen Color here:
            Text("")                               // just a placeholder for the toolbar
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
                .accentColor(.white)
                .onAppear {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithTransparentBackground()
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance  = appearance
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
                        .frame(width: 16, height: 16)           // ← smaller here
                        .offset(x: configuration.isOn ?  10 : -10)
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
    // ── Drawer & gesture state ───────────────────
    @State private var isDrawerOpen        = false
    @State private var dragOffset: CGFloat = 0
    @State private var blockingEnabled     = false
    @State private var showDisablePinAlert = false
    @State private var currentPage         = 1
    private let maxPage                   = 3

    // ── Dictionary state ──────────────────────────
    @State private var dictionaryText = ""
    @State private var searchText: String = ""
    @State private var debouncedSearchText: String = ""
    @State private var debounceTask: DispatchWorkItem?
    
    @State private var dictionaryLines = [String]()
    @State private var dictPage: Int   = 0
    private let linesPerPage          = 30
    
    @FocusState private var searchFieldIsFocused: Bool
    
    private var filteredLines: [String] {
      guard !debouncedSearchText.isEmpty else { return dictionaryLines }
      return dictionaryLines.filter {
        $0.lowercased().contains(debouncedSearchText.lowercased())
      }
    }

    var body: some View {
        ZStack(alignment: .leading) {
                NavigationView {
                    VStack(spacing: 0) {
                        NumbuXAppBar(isDrawerOpen: $isDrawerOpen,
                                     enabled: blockingEnabled)

                        if currentPage == 3 {
                            // dictionary jumps straight under the nav-bar
                            dictionaryView
                                .padding(.top, 0)
                        } else {
                            // pages 1 & 2 stay centered
                            Spacer()

                            if currentPage == 1 {
                                BasicCalculatorView()
                            } else {
                                ScientificCalculatorView()
                            }

                            Spacer()
                        }
                    }
                    .background(Color.black.ignoresSafeArea())
                    .navigationBarHidden(false)
                }
                .accentColor(.white)

            // ─── Scrim + Drawer ───────────────────────
            if isDrawerOpen {
                Color.black.opacity(0.2)
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
                        .offset(x: -w + (isDrawerOpen ? w : 0) + dragOffset)

                        Spacer()
                    }
                }
                .ignoresSafeArea()
            }
        }
        // ─── Load dictionary once on appear ─────────
        .onAppear(perform: loadDictionary)
        // ─── Global swipe gesture ───────────────────
        .highPriorityGesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .global)
                .onChanged { v in
                    if isDrawerOpen && v.translation.width < 0 {
                        dragOffset = v.translation.width
                    }
                }
                .onEnded { v in
                    let openThreshold  = 100.0
                    let closeThreshold = -100.0

                    if !isDrawerOpen {
                        if v.startLocation.x < 30 && v.translation.width > openThreshold {
                            withAnimation(.easeInOut) {
                                isDrawerOpen = true
                                dragOffset   = 0
                            }
                        }
                    } else {
                        if v.translation.width < closeThreshold {
                            withAnimation(.easeInOut) { closeDrawer() }
                        } else {
                            withAnimation(.easeInOut) { dragOffset = 0 }
                        }
                    }
                }
        )
        // ─── Disable‐PIN alert ──────────────────────
        .alert("Disable PIN?", isPresented: $showDisablePinAlert) {
            Button("Cancel", role: .cancel) { blockingEnabled = true }
            Button("OK")               { blockingEnabled = false }
        }
    }

    // MARK: – Helpers

    // The View that shows one “page” of lines plus Prev/Next controls
    private var dictionaryView: some View {
      VStack(spacing: 8) {
        // — Search field compacto con lupa —
        HStack(spacing: 8) {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.accentOrange)
            .font(.system(size: 20))
          TextField("Buscar palabra…", text: $searchText)
            .foregroundColor(.white)
            .font(.system(size: 20))
            .autocorrectionDisabled(true)
            .focused($searchFieldIsFocused)
            .onChange(of: searchText) { newValue in
              // debounceTask?.cancel()…
              // DispatchQueue.main.asyncAfter…
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 14)
        .background(
           RoundedRectangle(cornerRadius: 8)
             .fill(Color.white.opacity(0.1))
         )
         .overlay(
           RoundedRectangle(cornerRadius: 8)
             .stroke(
               searchFieldIsFocused ? Color.accentOrange : Color.clear,
               lineWidth: 2
             )
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)

        // — Paged, lazy list —
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(currentSlice, id: \.self) { line in
              Text(line)
                .foregroundColor(.white)
                .font(.system(size: 18, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          .padding()
        }

        // — Page controls —
        HStack {
          Button { if dictPage > 0 { dictPage -= 1 } } label: {
            Image(systemName: "chevron.left")
          }
          .disabled(dictPage == 0)

          Spacer()

          Text("Página \(dictPage+1) de \(totalPages)")
            .foregroundColor(.accentOrange)

          Spacer()

          Button { if dictPage < totalPages-1 { dictPage += 1 } } label: {
            Image(systemName: "chevron.right")
          }
          .disabled(dictPage >= totalPages-1)
        }
        .padding(.horizontal, 16)
        .foregroundColor(.white)
      }
    }

    // 3) Helper to grab the correct slice of lines
    private var currentSlice: [String] {
        let start = dictPage * linesPerPage
        let end   = min(start + linesPerPage, filteredLines.count)
        return Array(filteredLines[start..<end])
    }

    private var totalPages: Int {
        max(1, Int(ceil(Double(filteredLines.count) / Double(linesPerPage))))
    }

    // Finally, tweak your loadDictionary() to fill dictionaryLines instead of dictionaryText:
    private func loadDictionary() {
        guard let asset = NSDataAsset(name: "DiccionarioLatinEspanol"),
              let raw   = String(data: asset.data, encoding: .utf8)
        else {
            dictionaryLines = ["⚠️ No pude cargar el diccionario."]
            return
        }
        dictionaryLines = raw
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
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
