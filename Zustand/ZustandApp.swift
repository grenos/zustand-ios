//
//  ZustandApp.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//

import SwiftUI
import SwiftData

@main
struct ZustandApp: App {
    @State var tabIndex: Int = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $tabIndex) {
                BearListView()
                    .tabItem {
                        VStack {
                            Text("🧸")
                            Text("Bears")
                        }
                    }
                    .tag("bears")
                
                CatListView()
                    .tabItem {
                        VStack {
                            Text("🐈")
                        }
                    }
                    .tag("cats")
            }
        }
    }
}
