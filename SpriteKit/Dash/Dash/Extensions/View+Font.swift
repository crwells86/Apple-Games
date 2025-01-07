import SwiftUI

struct RetroFontModifier: ViewModifier {
    var size: CGFloat?
    var textStyle: Font.TextStyle?
    
    func body(content: Content) -> some View {
        if let size = size {
            content.font(.custom("04b03", size: size))
        } else if let textStyle = textStyle {
            let fontSize = UIFont.preferredFont(forTextStyle: textStyle.toUIFontTextStyle()).pointSize
            content.font(.custom("04b03", size: fontSize))
        } else {
            content
        }
    }
}

extension View {
    func retroFont(size: CGFloat) -> some View {
        self.modifier(RetroFontModifier(size: size, textStyle: nil))
    }
    
    func retroFont(style: Font.TextStyle) -> some View {
        self.modifier(RetroFontModifier(size: nil, textStyle: style))
    }
}

extension Font.TextStyle {
    func toUIFontTextStyle() -> UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
