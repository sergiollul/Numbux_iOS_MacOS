import Foundation
import FirebaseDatabase
import Combine

class FocusSyncViewModel: ObservableObject {
  @Published var isFocusModeOn: Bool = false

  private let ref: DatabaseReference
  private var handle: DatabaseHandle?
  private var cancellables = Set<AnyCancellable>()

  init(databaseURL: String = "https://numbux-790d6-default-rtdb.europe-west1.firebasedatabase.app") {
    // 1) point at the same key your teacher uses
    ref = Database.database(url: databaseURL)
              .reference(withPath: "settings/blocking_enabled")

    // 2) listen for remote changes
    handle = ref.observe(.value) { [weak self] snap in
      guard let self = self,
            let val = snap.value as? Bool else { return }
      DispatchQueue.main.async {
        if self.isFocusModeOn != val {
          self.isFocusModeOn = val
        }
      }
    }

    // 3) push any local toggles back to Firebase
    $isFocusModeOn
      .dropFirst()     // skip the initial read
      .sink { [weak self] newVal in
        self?.ref.setValue(newVal)
      }
      .store(in: &cancellables)
  }

  deinit {
    if let h = handle {
      ref.removeObserver(withHandle: h)
    }
  }
}
