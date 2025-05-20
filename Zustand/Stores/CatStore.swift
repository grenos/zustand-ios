//
//  CatStore.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//

import Boutique
import Bodega
import Combine
import SwiftUI

// MARK: CAT STORE IS STORED IN MEMORY WITH THE CUSTOM IMPLEMENTATION OF THE BODEGA STORE
let memoryEngine = MemoryStorageEngine()

//MARK: STORE CREATION
extension Store where Item == Cat {
    static let catsStore = Store(
        storage: memoryEngine,
    )
}


// MARK: MODEL DTO (same job as dto models)
struct Cat: Identifiable, Equatable, StorableItem {
    var id: String
    var name: String
//    var image: RemoteImage
}

// MARK: STORE (same job as our view models)
final class CatStore {
    // ─── Your live-updating array of cats ───
    @ObservationIgnored
    @Stored var cats: [Cat]
    
    private let store: Store<Cat>
    
    init(store: Store<Cat>) {
        self.store = store
        // hook the @Stored property into our boutique store
        self._cats = Stored(in: store)
        Task{ await checkEvents() }
    }
    
    func addCat(named name: String) async throws {
//        let image = try await getImage()
        let new = Cat(id: UUID().uuidString, name: name)
        try await store.insert(new)
    }
    
    func addCats(named names: [String]) async throws {
        for name in names {
            try await addCat(named: name)
        }
    }
    
    func remove(_ cat: Cat) async throws {
        try await store.remove(cat)
    }
    
    func removeAll() async throws {
        try await store.removeAll()
    }
}


extension CatStore {
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


extension CatStore {
    private func checkEvents() async {
        for await event in store.events {
            switch event.operation {
            case .initialized:
                print("Cats Store has initialized")
            case .loaded:
                print("Cats Store has loaded with cats", event.items)
            case .insert:
                print("Cats Store inserted cats", event.items)
            case .remove:
                print("Cats Store removed cats", event.items)
            }
        }
    }
}
