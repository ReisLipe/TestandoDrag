//
//  MainView.swift
//  TestingMacOs2
//
//  Created by Joao Filipe Reis Justo da Silva on 23/05/25.
//

import SwiftUI

struct MainView: View {
    @State var cards: [String] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fundo da tela principal
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack {
                    Text("MainView")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Pince o card para aumentar ou diminuir")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                
                if !cards.isEmpty {
                    ForEach(cards.indices, id: \.self) { index in
                        // Card arrastável
                        Card(text: cards[index], boundary: geometry.size)
                    }
                }
                
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            let randInt = Int.random(in: 1...1000)
                            addNewCard("New card (randInt: \(randInt))")
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                addNewCard("Testando o card.")
            }
        }
    }
    
    func addNewCard(_ cardText: String) {
        let firstCard = cardText
        cards.append(firstCard)
    }
}
