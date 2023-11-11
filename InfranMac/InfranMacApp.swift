//
//  InfranMacApp.swift
//  InfranMac
//
//  Created by Marek Żebrowski on 10/11/2023.
//

import SwiftUI
import Combine
import os

@main
struct InfranMacApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate : AppDelegate
    
    @StateObject private var imageP : ImagePlace = ImagePlace()
   

    var body: some Scene {
        WindowGroup {
            ContentView(model: imageP)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    appDelegate.$url.sink{ urlOpt in
                        Logger.events.info("onAppear \(String(describing: urlOpt), privacy: .public)")
                        if let url = urlOpt {
                            if let dirResult = openUrl(url:url) {
                                imageP.imageFiles = dirResult.images
                                imageP.image = dirResult.image
                                imageP.current = dirResult.myIndex
                            }
                        }
                    }.store(in: &appDelegate.cancellables)
                    DispatchQueue.main.async {
                        if let window = NSApplication.shared.windows.last {
                            window.toggleFullScreen(nil)
                        }
                    }
                }
        }
        .handlesExternalEvents(matching: [])
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
        
    func openUrl(url: URL) -> DirectoryResult? {
        let knownImageTypes = ["public.jpeg","public.heic","com.compuserve.gif","public.png"]
        let fm = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
        let keys: [URLResourceKey] = [.isRegularFileKey, .typeIdentifierKey]
        var imageFiles: [URL] = []
        var myIndex = -1
        if let enumerator = fm.enumerator(at: url.deletingLastPathComponent(), includingPropertiesForKeys: keys, options: options, errorHandler: nil) {
            for case let fileURL as URL in enumerator {
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))
                    if let isRegularFile = resourceValues.isRegularFile, isRegularFile {
                        if let typeIdentifier = resourceValues.typeIdentifier, knownImageTypes.contains(where: {typeIdentifier.contains($0)}){
                            imageFiles.append(fileURL)
                        }
                    }
                } catch {
                    Logger.events.warning("Error getting resource values for \(fileURL.path, privacy: .public): \(error.localizedDescription, privacy: .public)")
                }
            }
            imageFiles.sort(by: {$0.lastPathComponent < $1.lastPathComponent })
            myIndex = imageFiles.lastIndex(of: url) ?? -1
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
            Logger.events.warning("Exception \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    
    func openFile() -> DirectoryResult? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.image]
        openPanel.allowsMultipleSelection = false
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                return openUrl(url: url)
            } else {
                Logger.events.info("open panel url failed")
            }
        }
        return nil
    }

}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var url: URL?
    func application(_ application: NSApplication, open urls: [URL]) {
        url = urls.first
        let last = url?.lastPathComponent ?? ""
        Logger.events.warning("application \(last, privacy: .public)")
    }
    var cancellables = Set<AnyCancellable>()
}
