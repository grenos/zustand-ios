//
//  BearListView.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//


import SwiftUI
import UIKit

struct BearListView: View {
    @State var vm = BearViewModel()
    @State private var newName = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.store.bears) { bear in
                    Text("nickname: \(vm.store.username)")
                    HStack {
                        Text(bear.name)
                        Spacer()
                    }
                    .onTapGesture {
                        vm.store.$isBearsGood.toggle()
                    }
                }
                .onDelete { idxSet in
                    idxSet.forEach { index in
                        Task {
                            try? await vm.store.remove(vm.store.bears[index])
                        }
                    }
                }
            }
            .onChange(of: vm.store.bears, initial: true) { oldBears, newBears in
                print("bears updated with \(newBears.count) bears")
            }
            .navigationTitle("Bears (\(vm.store.bears.count))")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("Cats (\(vm.catStore.cats.count))")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Text("is bear good \( vm.store.isBearsGood)")
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        TextField("New bear name", text: $newName)
                            .textFieldStyle(.roundedBorder)

                        Button("Add") {
                            Task {
                                try? await vm.store.addBear(named: newName)
                                vm.store.username = newName
                                newName = ""
                            }
                        }
                        .disabled(newName.isEmpty)
                    }
                    .padding()
                }
            }
        }
    }
}
  
