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
                    HStack {
                        Text(bear.name)
                        Spacer()
//                        if let uiImage = UIImage(data: bear.image.dataRepresentation) {
//                            Image(uiImage: uiImage)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 50, height: 50)
//                                .clipShape(Circle())
//                        } else {
//                            Image(systemName: "photo")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 50, height: 50)
//                                .foregroundColor(.gray)
//                        }
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
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        TextField("New bear name", text: $newName)
                            .textFieldStyle(.roundedBorder)

                        Button("Add") {
                            Task {
                                try? await vm.store.addBear(named: newName)
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
  
