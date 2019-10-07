//
//  CreateFileModalView.swift
//  Attest
//
//  Created by Joseandro Luiz on 07/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI

struct CreateFileModalView: View {
    @EnvironmentObject var device : Device
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack {
            Text("Let's create your file!")
                .font(.largeTitle)
                .padding()
            if device.capacity != nil {
                Text("Free disk space: \(device.capacity!)MB")
                    .padding([.top, .bottom], 10)
            } else {
                Text("We could not load your disk free space. Please, make sure your have enough space to create your file!")
                    .padding([.top, .bottom], 10)
            }
            
            Button("Dismiss") {
                self.presentation.wrappedValue.dismiss()
            }
        }
    }
}

struct CreateFileModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateFileModalView()
                .environmentObject(Device())
            
            CreateFileModalView()
                .environmentObject(Device())
                .environment(\.colorScheme, .dark)
        }

    }
}

