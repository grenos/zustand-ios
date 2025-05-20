import SwiftUI
import SwiftData
import Observation

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
    var value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

// MARK: - KeyValueStore Singleton
@MainActor @Observable
final class KeyValueStore {
    let storeManager = StoreManager.shared
    
    private(set) var cache: [String: String] = [:]
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

    private func saveToDisk(_ key: String, value: String) async {
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

    func get(_ key: String) -> String? {
        cache[key]
    }

    func set(_ key: String, value: String) {
        cache[key] = value
        Task { @MainActor in
            await saveToDisk(key, value: value)
        }
    }

    func remove(_ key: String) {
        cache.removeValue(forKey: key)
        Task { @MainActor in
            await removeFromDisk(key)
        }
    }
}

//// MARK: - Property Wrapper
@MainActor @propertyWrapper
struct KVStored<Value> {
    private let key: String
    private let defaultValue: Value
    private let store: KeyValueStore
    
    init(key: String, default defaultValue: Value, store: KeyValueStore) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }
    
    var wrappedValue: Value {
        get {
            if let value = store.get(key) as? Value {
                return value
            }
            // If we're here, either the key doesn't exist or the value couldn't be cast
            // Let's check if the key exists at all
            if store.get(key) != nil {
                // Key exists but value couldn't be cast - this is an error case
                print("⚠️ [KVStored] Value for key '\(key)' exists but couldn't be cast to expected type")
                store.remove(key) // Clean up the invalid value
            }
            return defaultValue
        }
        nonmutating set {
            if let newString = newValue as? String {
                store.set(key, value: newString)
            } else if let optionalString = newValue as? String? {
                if let stringValue = optionalString {
                    store.set(key, value: stringValue)
                } else {
                    store.remove(key)
                }
            } else {
                // For non-String types, convert to string representation
                store.set(key, value: String(describing: newValue))
            }
        }
    }
    
    /// Completely removes the stored value for this key
    func remove() {
        store.remove(key)
    }
}
