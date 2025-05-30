import SwiftUI
import UniformTypeIdentifiers

// 1) Modelo de Card com cor e tamanho mutáveis
struct Card: Identifiable, Equatable {
    let id = UUID()
    var color: Color = .init(
        red:   .random(in: 0...1),
        green: .random(in: 0...1),
        blue:  .random(in: 0...1)
    )
    var width: CGFloat = 100
    var height: CGFloat = 80
}

// 2) Layout flow que respeita o tamanho de cada subview
struct FlowLayout: Layout {
    var spacing: CGFloat = 12
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let sz = subview.sizeThatFits(.unspecified)
            if x + sz.width > maxWidth {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            x += sz.width + spacing
            lineHeight = max(lineHeight, sz.height)
        }
        // conta a última linha
        y += lineHeight
        return CGSize(width: maxWidth, height: y)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let sz = subview.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(sz)
            )
            x += sz.width + spacing
            lineHeight = max(lineHeight, sz.height)
        }
    }
}

// 3) Delegate para swap on-drop
struct CardDropDelegate: DropDelegate {
    let target: Card
    @Binding var cards: [Card]
    @Binding var dragging: Card?

    func dropEntered(info: DropInfo) {
        guard
            let dragging = dragging,
            dragging != target,
            let from = cards.firstIndex(of: dragging),
            let to   = cards.firstIndex(of: target)
        else { return }
        withAnimation { cards.swapAt(from, to) }
    }
    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        return true
    }
}

// 4) View redimensionável e arrastável
struct ResizableDraggableCardView: View {
    @Binding var card: Card
    @Binding var cards: [Card]
    @Binding var draggingCard: Card?
    
    private let handleSize: CGFloat = 16
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(card.color)
            Text("Card")
                .bold()
                .foregroundColor(.white)
        }
        .frame(width: card.width, height: card.height)
        .overlay(
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: handleSize, height: handleSize)
                .overlay(Circle().stroke(Color.gray))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newW = max(50, card.width  + value.translation.width)
                            let newH = max(40, card.height + value.translation.height)
                            card.width  = newW
                            card.height = newH
                        }
                )
            , alignment: .bottomTrailing
        )
        .onDrag {
            draggingCard = card
            return NSItemProvider(object: card.id.uuidString as NSString)
        }
        .onDrop(
            of: [UTType.text],
            delegate: CardDropDelegate(
                target: card,
                cards: $cards,
                dragging: $draggingCard
            )
        )
    }
}

// 5) ContentView com FlowLayout
struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var draggingCard: Card?

    var body: some View {
        VStack(spacing: 0) {
            // Botão +
            HStack {
                Spacer()
                Button { cards.append(Card()) } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding([.top, .horizontal])
            
            // Grid em fluxo
            ScrollView {
                FlowLayout(spacing: 12) {
                    ForEach($cards, id: \.id) { $card in
                        ResizableDraggableCardView(
                            card: $card,
                            cards: $cards,
                            draggingCard: $draggingCard
                        )
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}
