//
//  InMemoryLayer.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//

import Bodega
import Boutique
import SwiftUI

/// An actor-based storage engine that lives only in memory.
actor MemoryStorageEngine: StorageEngine {
    private var dataStore: [CacheKey: Data] = [:]
    private var timestamps: [CacheKey: (created: Date, updated: Date)] = [:]

    // MARK: - Write

    func write(_ data: Data, key: CacheKey) async throws {
        let now = Date()
        if timestamps[key] == nil {
            timestamps[key] = (created: now, updated: now)
        } else {
            timestamps[key]?.updated = now
        }
        dataStore[key] = data
    }

    func write(_ dataAndKeys: [(key: CacheKey, data: Data)]) async throws {
        for (key, data) in dataAndKeys {
            try await write(data, key: key)
        }
    }

    // MARK: - Read

    func read(key: CacheKey) async -> Data? {
        return dataStore[key]
    }

    func read(keys: [CacheKey]) async -> [Data] {
        return keys.compactMap { dataStore[$0] }
    }

    func readDataAndKeys(keys: [CacheKey]) async -> [(key: CacheKey, data: Data)] {
        return keys.compactMap { key in
            dataStore[key].map { (key: key, data: $0) }
        }
    }

    func readAllData() async -> [Data] {
        return Array(dataStore.values)
    }

    func readAllDataAndKeys() async -> [(key: CacheKey, data: Data)] {
        return dataStore.map { (key: $0.key, data: $0.value) }
    }

    // MARK: - Remove

    func remove(key: CacheKey) async throws {
        dataStore.removeValue(forKey: key)
        timestamps.removeValue(forKey: key)
    }

    func remove(keys: [CacheKey]) async throws {
        for key in keys {
            dataStore.removeValue(forKey: key)
            timestamps.removeValue(forKey: key)
        }
    }

    func removeAllData() async throws {
        dataStore.removeAll()
        timestamps.removeAll()
    }

    // MARK: - Metadata

    func keyExists(_ key: CacheKey) async -> Bool {
        return dataStore[key] != nil
    }

    func keyCount() async -> Int {
        return dataStore.count
    }

    func allKeys() async -> [CacheKey] {
        return Array(dataStore.keys)
    }

    func createdAt(key: CacheKey) async -> Date? {
        return timestamps[key]?.created
    }

    func updatedAt(key: CacheKey) async -> Date? {
        return timestamps[key]?.updated
    }
}
