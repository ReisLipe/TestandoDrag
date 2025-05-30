//
//  CardView.swift
//  TestingMacOs2
//
//  Created by Joao Filipe Reis Justo da Silva on 23/05/25.
//

import SwiftUI

struct CardView: View {
    // Parâmetros
    @Binding var card: Card
    @Binding var allCards: [Card]
    let boundary: CGSize
    let cardIndex: Int
    
    // States
    @State private var dragOffset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    // Constantes
    let minCardWidth: Double = 150
    let minCardHeight: Double = 50
    let minScale: CGFloat = 0.5
    let maxScale: CGFloat = 3.0
    let repulsionDistance: CGFloat = 20
    
    var body: some View {
        Text(self.card.title)
        
        // MARK: Card Style
            .font(.headline)
            .foregroundStyle(.white)
            .frame(minWidth: self.minCardWidth, minHeight: self.minCardHeight)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
                    .shadow(color: Color.black.opacity(0.1), radius: 0, x: 8, y: 8)
            }
            .scaleEffect(self.scale)
        
        // MARK: Geometry
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.card.size = geometry.size
                            print("CardSize = \(self.card.size)")
                        }
                        .onChange(of: geometry.size) { oldValue, newValue in
                            self.card.size = newValue
                            print("CardSizeMUDOU = \(self.card.size)")
                        }
                }
            )
        
        // MARK: Gestures Logic
            .offset(x: card.position.width + dragOffset.width,
                    y: card.position.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        card.position.width += dragOffset.width
                        card.position.height += dragOffset.height
                        card.position = applyBoundaryLimits(card, x: card.position.width, y: card.position.height)
                        
                        // Reset do offset temporário
                        dragOffset = .zero
                        
                        // Resolve colisões
                        checkAndResolveCollisions(for: cardIndex, at: card.position)
                    }
                
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dragOffset)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
    }
    
    private func applyBoundaryLimits(_ card: Card, x: Double, y: Double) -> CGSize {
        print("==================== LIMITES =================================")
        
        // CARD
        let halfCardWidth = card.size.width * card.scale / 2
        let halfCardHeight = card.size.height * card.scale / 2
        print("(DEBUG) HalfCardWidth: \(halfCardWidth)")
        print("(DEBUG) HalfCardHeight: \(halfCardHeight)")
        print("")
        
        // BOUNDARY
        let halfBoundaryWidth = self.boundary.width / 2
        let halfBoundaryHeight = self.boundary.height / 2
        print("(DEBUG) HalfBoundaryWidth: \(halfBoundaryWidth)")
        print("(DEBUG) HalfBoundaryHeight: \(halfBoundaryHeight)")
        print("")
        
        // Limites considerando o tamanho do card
        let minX = -halfBoundaryWidth + halfCardWidth
        let maxX = halfBoundaryWidth - halfCardWidth
        
        let minY = -halfBoundaryHeight + halfCardHeight
        let maxY = halfBoundaryHeight - halfCardHeight
        
        let newX = min(maxX, max(x, minX))
        let newY = min(maxY, max(y, minY))
        
        print("==================== LIMITES - FIM ============================")
        
        return CGSize(width: newX, height: newY)
    }
    
    private func checkAndResolveCollisions(for currentIndex: Int, at position: CGSize) {
        let currentCard = allCards[currentIndex]
        let currentRect = getCardRect(for: currentCard, at: position)
        
        for (index, otherCard) in allCards.enumerated() {
            guard index != currentIndex else { continue }
            
            let otherRect = getCardRect(for: otherCard, at: otherCard.position)
            
            if currentRect.intersects(otherRect) {
                resolveCollision(currentIndex: currentIndex, otherIndex: index)
            }
        }
    }
    private func getCardRect(for card: Card, at position: CGSize) -> CGRect {
        let scaledWidth = card.size.width * card.scale
        let scaledHeight = card.size.height * card.scale
        
        return CGRect(
            x: position.width - scaledWidth / 2,
            y: position.height - scaledHeight / 2,
            width: scaledWidth,
            height: scaledHeight
        )
    }
    
    private func resolveCollision(currentIndex: Int, otherIndex: Int) {
        print("==================== COLISÃO =================================")
        print("(DEBUG) Resolvendo colisão entre: ")
        print("(DEBUG) \(allCards[currentIndex].title) (current) e \(allCards[otherIndex].title) (other)")
        print("")
        
        let currentCard = allCards[currentIndex]
        let otherCard = allCards[otherIndex]
        
        print("(DEBUG) CurrentCard posição: \(currentCard.position)")
        print("(DEBUG) OtherCard posição: \(otherCard.position)")
        print("")
        
        // Calcular vetor entre os centros dos cards
        let dx = otherCard.position.width - currentCard.position.width
        let dy = otherCard.position.height - currentCard.position.height
        let distance = sqrt(dx * dx + dy * dy)
        print("(DEBUG) Distância X entre os centros: \(dx)")
        print("(DEBUG) Distância Y entre os centros: \(dy)")
        print("(DEBUG) Distância TOTAL entre os centros: \(distance)")
        print("")
        
        // Evitar divisão por zero
        guard distance > 0 else { return }
        
        // Calcular distância mínima necessária
        let currentRadius = max(currentCard.size.width, currentCard.size.height) * currentCard.scale / 2
        let otherRadius = max(otherCard.size.width, otherCard.size.height) * otherCard.scale / 2
        let minDistance = currentRadius + otherRadius + repulsionDistance
        print("(DEBUG) CurrentCard raio: \(currentRadius)")
        print("(DEBUG) OtherCard raio: \(otherRadius)")
        print("(DEBUG) Distância Mínima Necessária: \(minDistance)")
        print("")
        
        // Se os cards estão muito próximos, afastar o outro card
        if distance < minDistance {
            print("(DEBUG) A distância total é MENOR que a distância mínima necessária!")
            
            let overlap = minDistance - distance
            print("(DEBUG) O overlap (sobreposição) é de \(overlap)")
            print("")
            
            // Normalizar o vetor de direção
            let normalizedDx = dx / distance
            let normalizedDy = dy / distance
            print("(DEBUG) Distância X normalizada \(normalizedDx)")
            print("(DEBUG) Distância Y normalizada \(normalizedDy)")
            print("")
            
            // Calcular novo posição para o outro card
            let tentativeX = otherCard.position.width + normalizedDx * overlap
            let tentativeY = otherCard.position.height + normalizedDy * overlap
            print("(DEBUG) Tentativa de posição X de OtherCard: \(tentativeX)")
            print("(DEBUG) Tentativa de posiçõa Y de OtherCard: \(tentativeY)")
            print("")
            
            // Aplicar limites de boundary
            let tentativePosition = applyBoundaryLimits(otherCard, x: tentativeX, y: tentativeY)
    
            let hitBoundaryX = abs(tentativePosition.width - tentativeX) > 1.0
            let hitBoundaryY = abs(tentativePosition.height - tentativeY) > 1.0
            
            var newX = tentativeX
            var newY = tentativeY
            
            if hitBoundaryX {
                print("(DEBUG) Bateu no limite horizontal - empurrando para o lado oposto")
                newX = currentCard.position.width - normalizedDx * minDistance
            }
            
            if hitBoundaryY {
                print("(DEBUG) Bateu no limite vertical - empurrando para o lado oposto")
                newY = currentCard.position.height - normalizedDy * minDistance
            }
            
            print("(DEBUG) Nova posição X de OtherCard: \(newX)")
            print("(DEBUG) Nova posição Y de OtherCard: \(newY)")
            print("")
            
            // Aplicar limites de boundary na posição final
            let newPosition = applyBoundaryLimits(otherCard, x: newX, y: newY)
            
            // Atualizar posição do outro card com animação
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                allCards[otherIndex].position = newPosition
            }
            
            print("(DEBUG) Nova posição atribuída ao OtherCard.")
            print("=====================================================")
            print("")
        }
    }
}
