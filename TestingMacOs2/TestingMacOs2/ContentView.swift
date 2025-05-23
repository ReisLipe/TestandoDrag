//
//  ContentView.swift
//  TestingMacOs2
//
//  Created by Joao Filipe Reis Justo da Silva on 20/05/25.
//

import SwiftUI

struct Option: Hashable {
    let name: String
    let image: String
}

struct ContentView: View {
    let options: [Option] = [
        .init(name: "Home", image: "house"),
        .init(name: "About", image: "info.circle"),
        .init(name: "Settings", image: "gear"),
        .init(name: "Social", image: "message")
    ]
    
    var body: some View {
        NavigationView {
            ListView(options: self.options)
            MainView()
        }
        // impede main view de ser esmagada
        .frame(minWidth: 600, minHeight: 400)
        
    }
}

struct ListView: View {
    let options: [Option]
    
    var body: some View {
        VStack (alignment: .leading){
            ForEach(options, id: \.self) { option in
                Button(action: {
                    
                }, label: {
                    HStack {
                        Image(systemName: option.image)
                            .resizable()
                            .scaledToFit()
                        Text(option.name)
                        Spacer()
                    }
                })
            }
            Spacer()
        }
    }
}



#Preview {
    ContentView()
}
