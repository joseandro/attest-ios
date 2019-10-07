//
//  Document.swift
//  Attest
//
//  Created by Joseandro Luiz on 06/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI

struct File : Identifiable, Equatable {
    var id = UUID()
    var name: String
    var size: UInt64
    var path: URL?
}

let testData = [
    File(name:"Test1", size: 100, path:nil),
    File(name:"A file", size: 1, path:nil ),
    File(name:"New", size: 54541210, path:nil),
    File(name:"Test", size: 848451020, path:nil),
    File(name:"Diff", size: 10, path:nil)
]
