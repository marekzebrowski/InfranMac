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
                //.background(Color.black)
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
                    if let img = openFile() {
                        imageP.image = img
                    }
                }
            }
        }
    }
    
    
    func openFile() -> NSImage? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.image]
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                do {let data = try Data(contentsOf: url)
                    let img = NSImage(dataIgnoringOrientation: data)
                    return img
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
