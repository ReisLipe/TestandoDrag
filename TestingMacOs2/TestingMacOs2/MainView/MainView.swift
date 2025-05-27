//
//  MainView.swift
//  TestingMacOs2
//
//  Created by Joao Filipe Reis Justo da Silva on 23/05/25.
//

import SwiftUI

struct MainView: View {
    @State var cards: [Card] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main View Background
                MainViewBckg()
                
                if !cards.isEmpty {
                    ForEach(cards.indices, id: \.self) { index in
                        
                        // Card arrastável
                        CardView(
                            card: $cards[index],
                            allCards: $cards,
                            boundary: geometry.size,
                            cardIndex: index
                        )
                    }
                }
                
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: { addNewCard() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                addNewCard()
            }
        }
    }
    
    func addNewCard() {
        let randInt = Int.random(in: 1...1000)
        let cardTitle = "New card (randInt: \(randInt))"
        cards.append(Card(id: UUID(), title: cardTitle))
    }
}
