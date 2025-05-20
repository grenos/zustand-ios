//
//  CatViewModel.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//

import SwiftUI

// MARK: THIS IS LIKE A HOOK THAT HANDLES VIEW LOGIC
@MainActor @Observable
class CatViewModel {
    // THIS MODEL IN STORED IN MEMORY
    let store = CatStore(store: .catsStore)
    let bearStore = BearStore(store: .bearsStore)
    // WE CAN LOAD MORE STORES HERE
    
}
