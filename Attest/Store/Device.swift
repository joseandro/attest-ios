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
    @Published var capacity: Int64? = 0
       
    init(){
        name = getDeviceName()
        capacity = getDeviceCapacity()
    }
    
    private func getDeviceName() -> String {
        return "Name"
    }
    
    private func getDeviceCapacity() -> Int64? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            return values.volumeAvailableCapacityForImportantUsage
        } catch {
            print("Error retrieving capacity: \(error.localizedDescription)")
            return nil
        }
    }
}
