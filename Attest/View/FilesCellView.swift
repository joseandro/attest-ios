//
//  FilesCellView.swift
//  Attest
//
//  Created by Joseandro Luiz on 06/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI

struct FilesCellView: View {
    var file : File
    var body: some View {
        HStack {
            Image(systemName: "doc")
                .resizable()
                .frame(width: 30.0, height: 40.0)
                .aspectRatio(1,  contentMode: .fit)
                .padding(.all)
            
            VStack(alignment: .leading) {
                Text("\(file.name)")
                    .font(.title)
                Text("Size: \(file.size) MB")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
//            Spacer()
//
//            Image(systemName: "square.and.arrow.up")
//                .padding(.all)
            
        }
    }
    
    private func removeItem(){
        print("File removal was requested")
    }
}

struct FilesCellView_Previews: PreviewProvider {
    static var previews: some View {
        FilesCellView(file: testData[0])
    }
}
