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
                    .font(.headline)

                Text("Size: \(file.size.sizeString())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//            Spacer()
//TODO: Add the sharing functionality
//            Spacer()
//            Image(systemName: "square.and.arrow.up")
//                .padding(.all)
            
        }
    }
}

struct FilesCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilesCellView(file: testData[0])
            FilesCellView(file: testData[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))

    }
}
