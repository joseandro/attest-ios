//
//  FilesView.swift
//  Attest
//
//  Created by Joseandro Luiz on 06/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI

struct FilesView: View {
    @EnvironmentObject var store : FileStore
    @EnvironmentObject var device : Device
    @State private var displayModal: Bool = false

    
    var body: some View {
        NavigationView {
            VStack{
                if store.files.count > 0 {
                    if device.freeCapacity != nil {
                        Text("Free disk space: \(device.freeCapacity!.sizeString())")
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
                        if device.freeCapacity != nil {
                            Text("Create files to see a list of your Documents folder here. Free disk space: \(device.freeCapacity!.sizeString())")
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
                        self.displayModal.toggle()
                    }
                    Spacer()
                }
                Text("Ads will run here")
            }
            .navigationBarTitle(Text("Attest"))
            .navigationBarItems(trailing:
                Button(action: {
                    self.displayModal.toggle()
                }){
                    Text("Create file")
                })
            .sheet(isPresented: $displayModal, onDismiss: {
                print(self.displayModal)
            }) {
                CreateFileModalView()
                    .environmentObject(self.device)
                    .environmentObject(self.store)
            }
        }
    }

    
    private func delete(at offsets: IndexSet) {
        if offsets.count > 1 {
            print("Got offsets for list deletion > 1")
            return
        }
        
        if let index = offsets.first {
            let fileToBeRemoved : File = store.files.remove(at: index)
            store.removeFile(file: fileToBeRemoved)
            self.device.readDeviceProperties()
        }
    }
    
}

struct FilesViewView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            FilesView()
                .environmentObject(Device())
                .environmentObject(FileStore(files: []))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            
            FilesView()
                .environmentObject(Device())
                .environmentObject(FileStore(files: testData))
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            
            FilesView()
                .environmentObject(Device())
                .environmentObject(FileStore(files: testData))
                .environment(\.colorScheme, .dark)
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
        }
    }
}

