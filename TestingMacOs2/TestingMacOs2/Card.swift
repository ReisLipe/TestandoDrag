//
//  Card.swift
//  TestingMacOs2
//
//  Created by Joao Filipe Reis Justo da Silva on 23/05/25.
//

import SwiftUI

struct Card: View {
    // Parâmetros
    let text: String
    let boundary: CGSize
    
    // States
    @State private var position = CGSize.zero
    @State private var dragOffset = CGSize.zero
    @State private var cardSize = CGSize.zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    // Constantes
    let minCardWidth: Double = 150
    let minCardHeight: Double = 50
    let minScale: CGFloat = 0.5
    let maxScale: CGFloat = 3.0
    
    var body: some View {
        Text(self.text)
        
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
                        self.cardSize = geometry.size
                        print("CardSize = \(self.cardSize)")
                    }
                    .onChange(of: geometry.size) { oldValue, newValue in
                        // Caso o tamanho do card se atualize de algum modo!!!
                        self.cardSize = newValue
                        print("CardSizeMUDOU = \(self.cardSize)")
                    }
                }
            )
        
            // MARK: Drag and Drop Logic
            .offset(x: position.width + dragOffset.width,
                    y: position.height + dragOffset.height)
            .gesture(
                SimultaneousGesture (
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            position.width += dragOffset.width
                            position.height += dragOffset.height
                            position = applyBoundaryLimits(x: position.width, y: position.height)
                            
                            // Reset do offset temporário
                            dragOffset = .zero
                        },
                    
                    MagnificationGesture()
                        .onChanged { value in
                            let newScale = lastScale * value
                            scale = min(maxScale, max(minScale, newScale))
                        }
                        .onEnded { value in
                            lastScale = scale
                        }
                )
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dragOffset)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
    }
    
    private func applyBoundaryLimits(x: Double, y: Double) -> CGSize {
        // TODO: adicionar ajuste com o Scale up and down.
        
        // CARD
        let halfCardWidth = self.cardSize.width / 2
        let halfCardHeight = self.cardSize.height / 2
        
        // BOUNDARY
        let halfBoundaryWidth = self.boundary.width / 2
        let halfBoundaryHeight = self.boundary.height / 2
        
        // Limites considerando o tamanho do card
        let minX = -halfBoundaryWidth + halfCardWidth
        let maxX = halfBoundaryWidth - halfCardWidth
        
        let minY = -halfBoundaryHeight + halfCardHeight
        let maxY = halfBoundaryHeight - halfCardHeight
        
        print("MinX = \(minX) - MaxX = \(maxX)")
        print("MinY = \(minY) - MaxY = \(maxY)")
        
        let newX = min(maxX, max(x, minX))
        let newY = min(maxY, max(y, minY))
        
        print("NewX = \(newX) - NewY = \(newY)")

        return CGSize(width: newX, height: newY)
    }
}
