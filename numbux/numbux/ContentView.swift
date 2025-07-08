//
//  ContentView.swift
//  numbux
//
//  Created by Sergio Sánchez on 8/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isDrawerOpen = false
    @State private var enabled = false

    var body: some View {
        NumbuXAppBar(isDrawerOpen: $isDrawerOpen, enabled: enabled)
    }
}

struct NumbuXAppBar: View {
    // Binding to control side‐menu open/closed
    @Binding var isDrawerOpen: Bool
    // Enabled state (locked vs unlocked)
    let enabled: Bool

    var body: some View {
        NavigationView {
            // Your main content goes here; using an empty placeholder for now
            Text("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Leading: menu button
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isDrawerOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(isDrawerOpen ? Color.orange : Color.white)
                                .padding(.leading, 18)
                        }
                    }

                    // Center: intentionally left empty

                    // Trailing: app logo
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image("logo_blanco_numbux")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.trailing, 6)
                    }
                }
                // Transparent background
                .background(Color.clear)
        }
        // Ensure nav bar itself is transparent
        .accentColor(.white)
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
