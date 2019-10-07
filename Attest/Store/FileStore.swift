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
                
                let file = File(name: filename, size: UInt64(size), path: path)
                
                //TODO: Update contains to compare between paths
                if !files.contains(file) {
                    files.append(file)
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
}
