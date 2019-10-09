//
//  FileStore.swift
//  Attest
//
//  Created by Joseandro Luiz on 06/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

import SwiftUI
import Combine

class FileStore : ObservableObject {
    @Published var files : [File]
    @Published var areFilesBeingCreated : Bool = false
    
    let KBYTE : Double = 1000;
    let queue = DispatchQueue(label: "com.attest.file-processing-queue", qos: .userInitiated)
    
    init(files: [File] = []) {
        self.files = files
        fetchFilesFromDirectory()
    }
    
    private func fetchFilesFromDirectory() {
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            
            for file in directoryContents {
                let filename = file.deletingPathExtension().lastPathComponent
                let size = try! file.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize!
                let path = file.absoluteURL
                
                let fileToBeAdded = File(name: filename, size: Int64(size), path: path)

                var isFileListed = false
                for listedFile in self.files {
                    if listedFile.path == fileToBeAdded.path {
                        isFileListed = true
                    }
                }

                if !isFileListed {
                    self.files.append(fileToBeAdded)
                }
            }
        } catch {
            print("We could not fetch files from directory \(error)")
        }
    }
    
    public func removeFile(file:File){
        do {
            if let url = file.path {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Error \(error) when we tried to remove file \(file)")
            
            //Reload the list when the call above fails
            fetchFilesFromDirectory()
        }
    }
    
    
    public func createFile(name: String,
                           withSize size:Int64,
                           completionHandler: @escaping (Double, Bool, Error?) -> Void) {
        areFilesBeingCreated = true
        let fileName = NSString(string: name)
        queue.async {
            let start = DispatchTime.now()
            let success = createFileWithCFunction(UnsafeMutablePointer<CChar>(mutating: fileName.utf8String), size)
            let duration = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds)
            
//            var error = NSError(domain:"", code:httpResponse.statusCode, userInfo:nil)
            DispatchQueue.main.async {
                self.areFilesBeingCreated = false
                //Update files array, needs to happen in the main thread
                self.fetchFilesFromDirectory()
                
                completionHandler(duration, success == 1, nil)

            }
        }
    }
}

extension Int64 {
    func sizeString(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = units
        bcf.countStyle = .file

        return bcf.string(fromByteCount: self)
     }
}
