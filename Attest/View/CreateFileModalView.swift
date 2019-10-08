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
    @State var isFileBeingCreated = false
    @State var spin = false
    
    var body: some View {
        VStack {
            Text(isFileBeingCreated ? "Creating your file..." : "Let's create your file!")
                .font(.largeTitle)
                .padding()
            if device.capacity != nil {
                Text("Free disk space: \(device.capacity!.sizeString())")
                    .padding(10)
            } else {
                Text("We could not load your disk free space. Please, make sure your have enough space to create your file!")
                    .padding([.top, .bottom], 10)
            }
            if isFileBeingCreated {
                Image(systemName: "arrow.2.circlepath.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    .onAppear() {
                        self.spin.toggle()
                    }
                
            } else {
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
            }
        }
        .disabled(isFileBeingCreated)
    }
    
    private func addFile(){
        //Only allow one file to be created at a time
        if !self.isFileBeingCreated {
            self.isFileBeingCreated = true
            store.createFile(name: UUID().uuidString, withSize: 4000000000) { (duration, success, error) in
                print("Duration: \(Double(duration) / 1_000_000_000), success: \(success), error \(String(describing: error)) ")
                self.isFileBeingCreated = false
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

