//
//  ContentView.swift
//  numbux
//
//  Created by Sergio Sánchez on 8/7/25.
//

import SwiftUI

// MARK: - Custom App Bar
struct NumbuXAppBar: View {
    @Binding var isDrawerOpen: Bool
    let enabled: Bool

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            Text("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { withAnimation { isDrawerOpen.toggle() } }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(isDrawerOpen ? .orange : .white)
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
    @State private var enabled = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                NumbuXAppBar(isDrawerOpen: $isDrawerOpen, enabled: enabled)
                BasicCalculatorView()
                    .padding()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
