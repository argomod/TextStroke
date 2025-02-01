import SwiftUI

// Creates view modifier extension
extension Text {
    func textStroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(TextStrokeModifier(strokeSize: width, strokeColor: color))
    }
}

// Creates `textStroke` view modifier
struct TextStrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue
    
    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }
    
    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .background(
                // Shape is masked to create the stroke
                Rectangle()
                    .fill(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
                
            )
    }
    
    func mask(content: Content) -> some View {
        Canvas { context, size in
            if let resolvedView = context.resolveSymbol(id: id) {
                context.draw(resolvedView, at: .init(x: size.width/2, y: size.height/2))
            }
        } symbols: {
            let diagonal: CGFloat = 1/sqrt(2) * strokeSize
            content
                .tag(id)
                .overlay {
                    // Copies of text content shifted in 8 directions. Should not be shifted more than the font glyph is thick.
                    ZStack {
                        // Top left
                        content.offset(x: -diagonal, y: -diagonal)
                        // Top
                        content.offset(x:  0, y: -strokeSize)
                        // Top right
                        content.offset(x:  diagonal, y: -diagonal)
                        // Right
                        content.offset(x:  strokeSize, y: 0)
                        // Bottom right
                        content.offset(x:  diagonal, y:  diagonal)
                        // Bottom
                        content.offset(x:  0, y: strokeSize)
                        // Bottom left
                        content.offset(x: -diagonal, y:  diagonal)
                        // Left
                        content.offset(x:  -strokeSize, y: 0)
                    }
                }
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Text stroke example")
            .font(.largeTitle)
            .foregroundColor(.yellow)
            .textStroke(color: .orange, width: 0.5)
    }
}

#Preview {
    ContentView()
}

