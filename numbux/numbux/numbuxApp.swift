//
//  numbuxApp.swift
//  numbux
//
//  Created by Sergio Sánchez on 8/7/25.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseDatabase
import Combine

@main
struct NumbuXApp: App {
  init() {
    FirebaseApp.configure()
  }
  var body: some Scene {
    WindowGroup {
      LoginView()
    }
  }
}
