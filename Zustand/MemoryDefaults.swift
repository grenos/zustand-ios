import SwiftUI
import SwiftData
import Foundation

// MARK: - StoreManager Singleton
@MainActor
class StoreManager {
    static let shared = StoreManager()

    static var container: ModelContainer? = nil
    static var mainContext: ModelContext? = nil

    private init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: KeyValueEntry.self, configurations: config)
            StoreManager.container = container
            StoreManager.mainContext = container.mainContext
            StoreManager.mainContext?.autosaveEnabled = true
        } catch {
            print("Failed to initialize ModelContainer: \(error)")
        }
    }
}

// MARK: - Model
@Model
final class KeyValueEntry {
    @Attribute(.unique) var key: String
    var value: Data
    
    init(key: String, value: Data) {
        self.key = key
        self.value = value
    }
}

// MARK: - KeyValueStore Singleton
@MainActor @Observable
final class KeyValueStore {
    let storeManager = StoreManager.shared
    
    private(set) var cache: [String: Data] = [:]
    static let shared = KeyValueStore()

    init() {
        loadCache()
    }

    private func loadCache() {
        guard let ctx = StoreManager.mainContext else {
            fatalError("ModelContext not initialized. Make sure StoreManager.shared is initialized early in app lifecycle.")
        }
        
        do {
            let descriptor = FetchDescriptor<KeyValueEntry>()
            let entries = try ctx.fetch(descriptor)
            cache = Dictionary(uniqueKeysWithValues: entries.map { ($0.key, $0.value) })
        } catch {
            print("Failed to load cache: \(error)")
            cache = [:]
        }
    }

    private func saveToDisk(_ key: String, value: Data) async {
        guard let ctx = StoreManager.mainContext else {
            fatalError("ModelContext not initialized. Make sure StoreManager.shared is initialized early in app lifecycle.")
        }
        
        do {
            let predicate = #Predicate<KeyValueEntry> { $0.key == key }
            let descriptor = FetchDescriptor<KeyValueEntry>(predicate: predicate)
            let entries = try ctx.fetch(descriptor)
            if let entry = entries.first {
                entry.value = value
            } else {
                let entry = KeyValueEntry(key: key, value: value)
                ctx.insert(entry)
            }
            try ctx.save()
            cache[key] = value
        } catch {
            print("Failed to save to disk: \(error)")
        }
    }

    private func removeFromDisk(_ key: String) async {
        guard let ctx = StoreManager.mainContext else {
            fatalError("ModelContext not initialized. Make sure StoreManager.shared is initialized early in app lifecycle.")
        }
        
        do {
            let predicate = #Predicate<KeyValueEntry> { $0.key == key }
            let descriptor = FetchDescriptor<KeyValueEntry>(predicate: predicate)
            let entries = try ctx.fetch(descriptor)
            if let entry = entries.first {
                ctx.delete(entry)
                try ctx.save()
                cache.removeValue(forKey: key)
            }
        } catch {
            print("Failed to remove from disk: \(error)")
        }
    }

    func get<T: Decodable>(_ key: String) -> T? {
        guard let data = cache[key] else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func set<T: Encodable>(_ key: String, value: T) {
        do {
            let data = try JSONEncoder().encode(value)
            cache[key] = data
            Task { @MainActor in
                await saveToDisk(key, value: data)
            }
        } catch {
            print("Failed to encode value: \(error)")
        }
    }

    func remove(_ key: String) {
        cache.removeValue(forKey: key)
        Task { @MainActor in
            await removeFromDisk(key)
        }
    }
}

// MARK: - Property Wrapper
@MainActor @propertyWrapper
struct CachedValue<Value: Codable> {
    private let key: String
    private let defaultValue: Value
    private let store: KeyValueStore
    
    init(key: String, default defaultValue: Value, store: KeyValueStore? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store ?? .shared
    }
    
    var wrappedValue: Value {
        get {
            store.get(key) ?? defaultValue
        }
        nonmutating set {
            store.set(key, value: newValue)
        }
    }
    
    /// Completely removes the stored value for this key
    func remove() {
        store.remove(key)
    }
}
