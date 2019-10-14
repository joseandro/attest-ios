//
//  Device.swift
//  Attest
//
//  Created by Joseandro Luiz on 06/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI
import Combine

class Device : ObservableObject {
    @Published var name : String = ""
    @Published var freeCapacity: Int? = 0
       
    init( ){
        readDeviceProperties()
    }
    
    public func readDeviceProperties() {
        name = getDeviceName()
        freeCapacity = getDeviceCapacity()
    }
    
    private func getDeviceName() -> String {
        return "Name"
    }
    
    private func getDeviceCapacity() -> Int? {
        let fileURL = URL(fileURLWithPath:"/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let capacity = values.volumeAvailableCapacity {
//                print("Available capacity for important usage: \(capacity)")
                return Int(capacity)
            }
            print("Capacity is unavailable")
            return nil
        } catch {
            print("Error retrieving capacity: \(error.localizedDescription)")
            return nil
        }
    }
}
