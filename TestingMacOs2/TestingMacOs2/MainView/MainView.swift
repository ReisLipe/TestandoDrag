//
//  MainView.swift
//  TestingMacOs2
//
//  Created by Joao Filipe Reis Justo da Silva on 23/05/25.
//

import SwiftUI

struct MainView: View {
    @State var cards: [Card] = []
    
    // Estados para zoom e pan da workbench
    @State private var workbenchScale: CGFloat = 1.0
    @State private var lastWorkbenchScale: CGFloat = 1.0
    @State private var workbenchOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    
    // Constantes para zoom
    private let minZoom: CGFloat = 0.1
    private let maxZoom: CGFloat = 5.0
    
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
            .scaleEffect(workbenchScale) // Apply zoom on the workbench
            .offset(x: workbenchOffset.width + dragOffset.width,
                    y: workbenchOffset.height + dragOffset.height) // Apply pan on the worbench
            .gesture(SimultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        self.dragOffset = value.translation
                    }
                    .onEnded { value in
                        workbenchOffset.width += dragOffset.width
                        workbenchOffset.height += dragOffset.height
                        
                        workbenchOffset = applyPanLimits(
                            offset: workbenchOffset,
                            geometry: geometry.size,
                            scale: workbenchScale
                        )
                        
                        dragOffset = .zero
                    },
                MagnificationGesture()
                    .onChanged { value in
                        let newScale = lastWorkbenchScale * value
                        workbenchScale = min(maxZoom, max(minZoom, newScale))
                        print("Workbench Scale: \(workbenchScale)")
                    }
                    .onEnded { value in
                        lastWorkbenchScale = workbenchScale
                                                        
                        // Reajusta limites do pan após zoom
                        workbenchOffset = applyPanLimits(
                            offset: workbenchOffset,
                            geometry: geometry.size,
                            scale: workbenchScale
                        )
                    }
            ))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: workbenchOffset)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: workbenchScale)
        }
    }
    
    func addNewCard() {
        let randInt = Int.random(in: 1...1000)
        let cardTitle = "New card (randInt: \(randInt))"
        cards.append(Card(id: UUID(), title: cardTitle))
    }
    
    func applyPanLimits(offset: CGSize, geometry: CGSize, scale:CGFloat) -> CGSize {
        let maxOffset: CGFloat = 1000 * scale
                
        let newX = min(maxOffset, max(-maxOffset, offset.width))
        let newY = min(maxOffset, max(-maxOffset, offset.height))
        
        return CGSize(width: newX, height: newY)
    }
}
