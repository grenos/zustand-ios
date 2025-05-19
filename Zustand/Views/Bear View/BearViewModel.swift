//
//  BearViewModel.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//

import SwiftUI
import Boutique

// MARK: THIS IS LIKE A HOOK THAT HANDLES VIEW LOGIC
@MainActor @Observable
class BearViewModel {
    let store = BearStore(store: .bearsStore)
    let catStore = CatStore(store: .catsStore)
    // WE CAN LOAD MORE STORES HERE
}
