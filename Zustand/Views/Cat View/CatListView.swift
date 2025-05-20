//
//  CatListView.swift
//  Zustand
//
//  Created by Vasileios  Gkreen on 19/05/25.
//

import SwiftUI

struct CatListView: View {
    @State var vm = CatViewModel()
    @State private var newName = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.store.cats) { cat in
                    Text("username: \(vm.bearStore.username)")
                    HStack {
                        Text(cat.name)
                        Spacer()
//                        if let uiImage = UIImage(data: cat.image.dataRepresentation) {
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
                            try? await vm.store.remove(vm.store.cats[index])
                        }
                    }
                }
            }
            .onChange(of: vm.store.cats, initial: true) { oldBears, newBears in
                print("bears updated with \(newBears.count) bears")
            }
            .navigationTitle("Cats (\(vm.store.cats.count))")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        TextField("New bear name", text: $newName)
                            .textFieldStyle(.roundedBorder)

                        Button("Add") {
                            Task {
                                try? await vm.store.addCat(named: newName)
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

#Preview {
    CatListView()
}
