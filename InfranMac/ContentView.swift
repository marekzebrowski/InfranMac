//
//  ContentView.swift
//  InfranMac
//
//  Created by Marek Żebrowski on 10/11/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var image: ImagePlace

    init(model: ImagePlace) {
        image = model
    }

    var body: some View {
        VStack {
            if let i = self.image.image {
                Image(nsImage: i)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("No image")
            }
        }
    }
    
}

#Preview {
    ContentView(model: ImagePlace())
}
