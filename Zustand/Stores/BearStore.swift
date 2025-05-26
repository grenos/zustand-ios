//
//  BearStore.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//

import Bodega
import Boutique
import SwiftUI

//MARK: STORE CREATION
extension Store where Item == Bear {
  static let bearsStore = Store(
    storage: SQLiteStorageEngine.default(appendingPath: "Bears"),
  )
}

// MARK: MODEL DTO (same job as dto models)
struct Bear: Identifiable, Equatable, StorableItem {
  var id: String
  var name: String
  //    var image: RemoteImage
}

// MARK: STORE (same job as our view models)
@MainActor
final class BearStore {
  private let store: Store<Bear>

  let catStore = CatStore(store: .catsStore)

  private var gino = "gino"

  // persisted SQL Array
  @Stored var bears: [Bear]

  // persisted single value
  @StoredValue(key: "isBearsGood", default: true)
  var isBearsGood

  // in memory signle value
  @CachedValue(key: "username", default: "none")
  var username: String

  init(store: Store<Bear>) {
    self.store = store
    // hook the @Stored property into our boutique store
    self._bears = Stored(in: store)
    Task { await checkEvents() }
  }
}

// MARK: METHODS
extension BearStore {
  func addBear(named name: String) async throws {
    //        let image = try await getImage()
    let new = Bear(id: UUID().uuidString, name: name)
    try await store.insert(new)
  }

  func addBears(named names: [String]) async throws {
    for name in names {
      try await addBear(named: name)
    }
  }

  func remove(_ bear: Bear) async throws {
    try await store.remove(bear)
  }

  func removeAll() async throws {
    try await store.removeAll()
  }

  // optional (if we want to completely remove the key from the memoryDefaults)
  func removeUsername() {
    KeyValueStore.shared.remove("username")
  }
}

// MARK: NETWORK
extension BearStore {
  private func getImage() async throws -> RemoteImage {
    let imageURL = URL(string: "https://loremflickr.com/300/300")!
    let imageRequest = URLRequest(url: imageURL)
    let (data, response) = try await URLSession.shared.data(for: imageRequest)
    guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
      throw URLError(.badServerResponse)
    }
    return RemoteImage(url: imageURL, dataRepresentation: data)
  }
}

// MARK: STORE UTILITIES
extension BearStore {
  private func checkEvents() async {
    for await event in store.events {
      switch event.operation {
      case .initialized:
        print("Bears Store has initialized")
      case .loaded:
        print("Bears Store has loaded with bears", event.items)
      case .insert:
        print("Bears Store inserted bears", event.items)
      case .remove:
        print("Bears Store removed bears", event.items)
      }
    }
  }
}
