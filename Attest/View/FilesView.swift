//
//  FilesView.swift
//  Attest
//
//  Created by Joseandro Luiz on 06/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI

struct FilesView: View {
    @ObservedObject var store = FileStore()
    @EnvironmentObject var device : Device
    @State private var displayModal: Bool = false
    
    var body: some View {
        NavigationView {
            VStack{
                if store.files.count > 0 {
                    if device.capacity != nil {
                        Text("Free disk space: \(device.capacity!)MB")
                            .padding([.top, .bottom], 10)
                    }
                    List {
                        ForEach(store.files) { file in
                            FilesCellView(file: file)
                        }
                        .onDelete(perform: delete)
                    }
                    Divider()
                } else {
                    Spacer()
                    VStack {
                        Text("No files yet")
                            .font(.largeTitle)
                        if device.capacity != nil {
                            Text("Create files to see a list of your Documents folder here. Free disk space: \(device.capacity!)MB")
                                .font(.body)
                                .lineLimit(3)
                        } else {
                            Text("Create files to see a list of your Documents folder here.")
                            .font(.body)
                            .lineLimit(3)
                        }

                    }
                    .multilineTextAlignment(.center)
                    .padding([.trailing, .leading], 20)
                    .onTapGesture {
                        self.addFile()
                    }
                    Spacer()
                }
                Text("Ads will run here")
            }
            .navigationBarTitle(Text("Attest"))
            .navigationBarItems(trailing:
                Button(action: addFile) {
                    Text("Create file")
                })
            .sheet(isPresented: $displayModal, onDismiss: {
                print(self.displayModal)
            }) {
                CreateFileModalView()
            }
            
        }
    }
    
    private func addFile(){
        print("Create file tapped!")
        self.displayModal = true
    }
    
    private func delete(at offsets: IndexSet) {
        let fileToBeRemoved : File = store.files.removeLast()
        store.removeFile(file: fileToBeRemoved)
    }
    
}

struct FilesViewView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilesView(store: FileStore(files: []))
                .environmentObject(Device())
            
            FilesView(store: FileStore(files: testData))
                .environmentObject(Device())
            
            FilesView(store: FileStore(files: testData))
                .environmentObject(Device())
                .environment(\.colorScheme, .dark)
        }

    }
}

