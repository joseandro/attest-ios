//
//  ContentView.swift
//  Attesto
//
//  Created by Joseandro Luiz on 13/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics
import GoogleMobileAds
import UIKit

struct GADBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        let viewController = UIViewController()
        view.adUnitID = "ca-app-pub-7325018484688424/2387702452" //PROD
//        view.adUnitID = "ca-app-pub-3940256099942544/2934735716" //TEST
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        view.load(GADRequest())
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ContentView: View {
    let fileCreationOpQueue : OperationQueue = {
      var queue = OperationQueue()
      queue.name = "com.attesto.file-creation-op-queue"
      queue.maxConcurrentOperationCount = 1
      return queue
    }()
    
    let fileDeletionOpQueue : OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.attesto.file-deletion-op-queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    @EnvironmentObject var device : Device
    
    @State private var error: AlertError?
    @State private var areFilesBeingCreated : Bool = false
    @State private var areFilesBeingDeleted : Bool = false
    @State private var fileSizeString: String = ""
    @State private var workItem: BlockOperation?
    
    private var fileSize : Int? {
        get {
            return Int(fileSizeString)
        }
    }
    
    private let MAX_FREE_SPACE : Int = 0 //In bytes
    
    var totalCapacity : Int {
        get {
            if let cap = device.freeCapacity {
                return cap - MAX_FREE_SPACE
            }
            return 0
        }
    }
    
    var actionAtTheMoment : String {
        get {
            if areFilesBeingDeleted && areFilesBeingCreated {
                return "Creating and deleting files"
            } else if areFilesBeingDeleted {
                return "Deleting files. Space now available:"
            } else if areFilesBeingCreated {
                return "Creating files. Space now available:"
            }
            
            return "Live available disk space:"
        }
    }
    
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        VStack{
            Text("Attesto")
                .font(Font.custom("AllertaStencil-Regular", size: 60))
                .padding(.top, 10)
            Text("Fills up your storage space")
                .font(.footnote)
            Spacer()
            
            if device.freeCapacity != nil {
                Text(actionAtTheMoment)
                    .padding(.vertical, 10)
                    .font(.body)
                    .transition(.opacity)
                    .animation(.default)
                
                Text("\(device.freeCapacity!.sizeString())")
                    .padding(.vertical, 10)
                    .font(Font.custom("AllertaStencil-Regular", size: 40))
                    .onReceive(timer) {_ in
                        self.device.readDeviceProperties()
                    }
                Spacer()
                VStack {
                    Button(action: {
                        self.handleDeviceFillUp()
                        self.areFilesBeingCreated.toggle()
                    }){
                        HStack {
                            Image(systemName: areFilesBeingCreated ? "nosign" : "flame")
                                .font(.title)
                                .padding(.trailing, 10)
                            Text(areFilesBeingCreated ? "Stop it" : "Fill up device space")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, maxHeight: 20)
                        .padding()
                        .foregroundColor(.white)
                        .background((areFilesBeingDeleted) ? hexColor(0xd1ccc0) : hexColor(0x33d9b2))
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                        .animation(.default)
                    }.alert(item: $error, content: { error in
                        alert(reason: error.reason)
                    }).disabled((areFilesBeingDeleted))
                    
                    Button(action: {
                        self.removeFiles()
                        self.areFilesBeingDeleted.toggle()
                    }){
                        HStack {
                            Image(systemName: areFilesBeingDeleted ? "nosign" : "trash")
                                .font(.title)
                                .padding(.trailing, 10)
                            
                            Text(areFilesBeingDeleted ? "Stop it" : "Remove Attesto files")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, maxHeight: 20)
                        .padding()
                        .foregroundColor(.white)
                        .background((areFilesBeingCreated) ? hexColor(0xd1ccc0) : hexColor(0xff5252))
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                        .animation(.default)
                    }.disabled((areFilesBeingCreated))
                    GADBannerViewController()
                        .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
                }
                .padding(.bottom, 10)
            } else {
                Text("We were not capable of reading your device's free capacity")
            }
        }
    }
    
    private func fetchFilesFromDirectory() -> [URL] {
        // Get the document directory url
        var files = [URL]()
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            
            for file in directoryContents {
                let path = file.absoluteURL
                files.append(path)
            }
        } catch {
            print("We could not fetch files from directory \(error)")
        }
        
        return files
    }
    
    public func removeFiles(){
        if areFilesBeingDeleted == true {
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-remove-files-cancel",
                AnalyticsParameterItemName: "Remove Files Cancel",
                AnalyticsParameterContentType: "fileRemovalCancel"
            ])
            fileDeletionOpQueue.cancelAllOperations()
            print("Requested it to end all delete ops")
        } else {
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-remove-files",
                AnalyticsParameterItemName: "Remove Files",
                AnalyticsParameterContentType: "fileRemoval"
            ])

            print("Removing files")
            let operation = BlockOperation()
            operation.addExecutionBlock {
                do {
                    let files = self.fetchFilesFromDirectory()
                    for file in files {
                        try FileManager.default.removeItem(at: file)
                        if operation.isCancelled {
                            break
                        }
                    }
                } catch {
                    print("Error \(error) when we tried to remove files")
                }
                print("Ended removing files")
                self.areFilesBeingDeleted = false
            }
            fileDeletionOpQueue.addOperation(operation)
        }
    }
    
    private func handleDeviceFillUp(){
        if areFilesBeingCreated == true {
            fileCreationOpQueue.cancelAllOperations()
            print("Requested it to end all write ops")
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-device-fillup-cancel",
                AnalyticsParameterItemName: "Fill Up Device Cancel",
                AnalyticsParameterContentType: "fillUpCancel"
            ])

        } else {
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-device-fillup",
                AnalyticsParameterItemName: "Fill Up Device",
                AnalyticsParameterContentType: "fillUp"
            ])

            let operation = BlockOperation()
            operation.addExecutionBlock {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                    let data = Data(repeating: 7, count: 1_000_000)
                    let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
                    var output = 1
                    while (!operation.isCancelled && (output > 0) && (self.totalCapacity > 0)) {
                        var fileURL = dir.appendingPathComponent(UUID().uuidString)
                        print("Creating file \(fileURL)")
                        if let outputStream = OutputStream(url: fileURL, append: true) {
                            outputStream.open()
                            var totalWritten = 0
                            while (!operation.isCancelled && (output > 0) && (totalWritten < 512_000_000)) {
                                output = outputStream.write(data, bytes) //1MB
                                totalWritten += output
                            }
                            outputStream.close()
                            
                            fileURL.excludeFromBackup()
                        } else {
                            print("Unable to open file")
                            output = -2
                            self.error = AlertError(reason: "We were unable to create files in this device, check if you have enough storage space.")
                        }
                    }
                    
                    if !operation.isCancelled {
                        self.error = AlertError(reason: "This is how far iOS allowed us to write to the disk. You may want to wait while iOS manages and reallocates its own storage space and then try again.")
                    }
                } else {
                    self.error = AlertError(reason: "We were unable to access this device storage space, check if you have enough storage space.")
                }
                self.areFilesBeingCreated = false
            }

            fileCreationOpQueue.addOperation(operation)
        }
    }
    
    func alert(reason: String) -> Alert {
        Alert(title: Text("Error creating the file"),
              message: Text(reason),
              dismissButton: .default(Text("OK"))
        )
    }
    
    struct AlertError: Identifiable {
        var id: String {
            return reason
        }
        
        let reason: String
    }
    
}


extension OutputStream {
    func write(_ data:Data,_ bytes:UnsafePointer<UInt8>) -> Int {
        let bytesWritten = self.write(bytes, maxLength: data.count)
        return bytesWritten
    }
}

extension URL {
    mutating func excludeFromBackup() {
        var rv = URLResourceValues()
        rv.isExcludedFromBackup = true
        do {
            try self.setResourceValues(rv)
        } catch {
            print("Could not stop file from being backed up")
        }
        
    }
}


extension Int {
    func sizeString(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = units
        bcf.countStyle = .file
        
        return bcf.string(fromByteCount: Int64(self))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(Device())
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            
            ContentView()
                .environmentObject(Device())
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            
            ContentView()
                .environmentObject(Device())
                .environment(\.colorScheme, .dark)
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
        }
    }
}



extension Color {
    init(_ hex: UInt32, opacity:Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

let hexColor:(UInt32) -> (Color) = {
    return Color($0)
}
