//
//  ImagePlace.swift
//  InfranMac
//
//  Created by Marek Żebrowski on 11/11/2023.
//

import Foundation
import SwiftUI
import os
class ImagePlace: ObservableObject {
    @Published var image: NSImage?
    var imageFiles: [URL] = []
    var current: Int = -1
    
    func loadImg(url:URL) {
        do {let data = try Data(contentsOf: url)
            let img = NSImage(dataIgnoringOrientation: data)
            Logger.events.info("Loading file \(url.lastPathComponent, privacy: .public) index \(self.current+1, privacy: .public) of \(self.imageFiles.count, privacy: .public)")
            image = img
        } catch {
        }
    }
    
    func next() {
        if(current >= imageFiles.endIndex - 1 ) {
            return
        } else {
            current = current + 1
            loadImg(url: imageFiles[current])
        }
    }
    
    func prev() {
        if(current < 1 ) {
            return
        } else {
            current = current - 1
            loadImg(url: imageFiles[current])
        }
    }
    
}
