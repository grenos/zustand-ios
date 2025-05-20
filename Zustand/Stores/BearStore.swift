//
//  BearStore.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//


import Boutique
import Bodega
import Combine
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
@Observable
final class BearStore {
    private let store: Store<Bear>
    
    // persisted SQL Array
    @ObservationIgnored
    @Stored var bears: [Bear]
    
    // persisted single value
    @ObservationIgnored
    @StoredValue(key: "isBearsGood")
    var isBearsGood = true
    
    // in memory signle value
    @ObservationIgnored
    @KVStored(key: "username", default: "none", store: .shared)
    var username: String
            
    init(store: Store<Bear>) {
        self.store = store
        // hook the @Stored property into our boutique store
        self._bears = Stored(in: store)
        Task{ await checkEvents() }
    }
            
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
