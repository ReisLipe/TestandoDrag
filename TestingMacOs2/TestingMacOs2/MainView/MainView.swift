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
                        
                        // Movable Card
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
                        Button(action: { addNewCard(geometry: geometry) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                addNewCard(geometry: geometry)
            }
        }
    }
    
    private func addNewCard(geometry: GeometryProxy) {
        print("==================== ADDING CARD =================================")
        print("(DEBUG) Adicionando um novo Card ")
        print("")
        
        let randInt = Int.random(in: 1...1000)
        let cardTitle = "New card (randInt: \(randInt))"
        var newCard = Card(id: UUID(), title: cardTitle)
        print("(DEBUG) Novo Card criado (\(newCard.title)")
        print("")
        
        newCard.position = calculateCardInsertPosition(for: newCard, in: geometry.size)
        cards.append(newCard)
        print("==================== FIM - ADDING CARD =================================")
        print("(DEBUG) Card adicionado (\(newCard.title))")
        print("")
    }
    
    private func calculateCardInsertPosition(for newCard: Card, in boundarySize: CGSize) -> CGSize {
        print("=============== CARD INSERT POS ================")
        print("(DEBUG) Calculando a posição de inserção do Card (\(newCard.title))")
        print("")
        
        

        
        
        
        let spacing: CGFloat = 20
        let cardWidth = newCard.size.width
        let cardHeight = newCard.size.height
        
        let minX = -boundarySize.width/2 + cardWidth/2 + spacing
        let maxX = boundarySize.width/2 - cardWidth/2 - spacing
        let minY = -boundarySize.height/2 + cardHeight/2 + spacing
        let maxY = boundarySize.height/2 - cardHeight/2 - spacing
        
        // Começar sempre do canto superior esquerdo
        var testX = minX
        var testY = minY
        
        // Grid de posições possíveis
        let stepX = cardWidth + spacing
        let stepY = cardHeight + spacing
        // TODO: Isso aqui talvez devesse checar os tamanhos dos cards da lista.
        
        while testY <= maxY {
            testX = minX
            
            while testX <= maxX {
                let testPosition = CGSize(width: testX, height: testY)
                
                // Verificar se esta posição não colide com nenhum card existente
                if !hasCollision(at: testPosition, for: newCard) {
                    return testPosition
                }
                
                testX += stepX
            }
            testY += stepY
        }
        
        return CGSize(width: minX, height: minY)
    }
    
    private func hasCollision(at position: CGSize, for newCard: Card) -> Bool {
        let newCardRect = CGRect(
            x: position.width - newCard.size.width/2,
            y: position.height - newCard.size.height/2,
            width: newCard.size.width,
            height: newCard.size.height
        )
        
        for existingCard in cards {
            let existingRect = CGRect(
                x: existingCard.position.width - existingCard.size.width * existingCard.scale/2,
                y: existingCard.position.height - existingCard.size.height * existingCard.scale/2,
                width: existingCard.size.width * existingCard.scale,
                height: existingCard.size.height * existingCard.scale
            )
            
            // Adicionar uma margem de segurança
            let expandedExistingRect = existingRect.insetBy(dx: -10, dy: -10)
            
            if newCardRect.intersects(expandedExistingRect) {
                return true
            }
        }
        
        return false
    }
    
//    private func setCardInPos(_ card: Card, at position: Int) {
//        if position == 0 {
//            cards[position] = card
//            
//            card.position = 
//        }
//    }
}
