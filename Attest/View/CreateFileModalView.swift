//
//  CreateFileModalView.swift
//  Attest
//
//  Created by Joseandro Luiz on 07/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI
import Combine

struct CreateFileModalView: View {
    @EnvironmentObject var store : FileStore
    @EnvironmentObject var device : Device
    @Environment(\.presentationMode) var presentation
    @State var spin = false
    
    var body: some View {
        VStack {
            Text(store.areFilesBeingCreated ? "Creating your file..." : "Let's create your file!")
                .font(.largeTitle)
                .padding()
            if device.freeCapacity != nil {
                Text("\(device.freeCapacity!.sizeString()) free disk space")
                    .font(.body)
                    .padding(10)
                
                if !store.areFilesBeingCreated {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.addFile()
                        }){
                            Text("Create File")
                        }
                        Spacer()
                        Button(action: {
                            self.presentation.wrappedValue.dismiss()
                        }){
                            Text("Dismiss")
                        }
                        Spacer()
                    }
                } else {
                    Image(systemName: "arrow.2.circlepath.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                        .onAppear() {
                            self.spin.toggle()
                        }
                }
                
            } else {
                Text("We could not load your disk free space. Please, make sure your have enough space to create your file!")
                    .padding([.top, .bottom], 10)
            }
        }
        .disabled(store.areFilesBeingCreated)
    }
    
    private func addFile(){
        //Only allow one file to be created at a time
        if !store.areFilesBeingCreated {
            store.createFile(name: UUID().uuidString, withSize: 4000000000) { (duration, success, error) in
                print("Duration: \(Double(duration) / 1_000_000_000), success: \(success), error \(String(describing: error)) ")
                self.device.readDeviceProperties()
    //            if success {
    //
    //            } else {
    //
    //            }
            }
        }
    }
}

struct CreateFileModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateFileModalView()
                .environmentObject(Device())
                .environmentObject(FileStore(files: []))
            
            CreateFileModalView()
                .environmentObject(Device())
                .environmentObject(FileStore(files: testData))
                .environment(\.colorScheme, .dark)
        }

    }
}

