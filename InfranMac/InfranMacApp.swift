//
//  InfranMacApp.swift
//  InfranMac
//
//  Created by Marek Żebrowski on 10/11/2023.
//

import SwiftUI

@main
struct InfranMacApp: App {
    @StateObject private var imageP : ImagePlace = ImagePlace()
    var body: some Scene {
        WindowGroup {
            ContentView(model: imageP)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                                    DispatchQueue.main.async {
                                        if let window = NSApplication.shared.windows.last {
                                            window.toggleFullScreen(nil)
                                        }
                                    }
                                }
        }
        .commands{
            CommandGroup(replacing: .newItem) {
                Button("OpenFile") {
                    if let dirResult = openFile() {
                        imageP.imageFiles = dirResult.images
                        imageP.image = dirResult.image
                        imageP.current = dirResult.myIndex
                    }
                }
                Button("next") {
                    imageP.next()
                }.keyboardShortcut(KeyEquivalent.rightArrow)
                Button("prev") {
                    imageP.prev()
                }.keyboardShortcut(KeyEquivalent.leftArrow)
            }
        }
    }
    
    func openFile() -> DirectoryResult? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.image]
        openPanel.allowsMultipleSelection = false
        let knownImageTypes = ["public.jpeg","public.heic","com.compuserve.gif","public.png"]
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                let fm = FileManager.default
                let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
                let keys: [URLResourceKey] = [.isRegularFileKey, .typeIdentifierKey]
                var imageFiles: [URL] = []
                var myIndex = -1
                var fileIndex = -1
                if let enumerator = fm.enumerator(at: url.deletingLastPathComponent(), includingPropertiesForKeys: keys, options: options, errorHandler: nil) {
                    for case let fileURL as URL in enumerator {
                        do {
                            let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))
                            if let isRegularFile = resourceValues.isRegularFile, isRegularFile {
                                if let typeIdentifier = resourceValues.typeIdentifier, knownImageTypes.contains(where: {typeIdentifier.contains($0)}){
                                    imageFiles.append(fileURL)
                                    fileIndex = fileIndex + 1
                                    if(fileURL == url) {
                                        myIndex = fileIndex
                                    }
                                }
                            }
                        } catch {
                            print("Error getting resource values for \(fileURL.path): \(error)")
                        }
                    }
                }
                do {let data = try Data(contentsOf: url)
                    let img = NSImage(dataIgnoringOrientation: data)
                    let res = DirectoryResult(
                        image: img,
                        images: imageFiles,
                        myIndex: myIndex,
                        path:url.deletingLastPathComponent()
                    )
                    return res
                } catch {
                    print("Exception \(error.localizedDescription)")
                }
            } else {
                print("open panel url failed")
            }
        }
        return nil
    }

}
