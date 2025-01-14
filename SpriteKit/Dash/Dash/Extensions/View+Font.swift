import SwiftUI

struct RetroFontModifier: ViewModifier {
    var size: CGFloat?
    var textStyle: Font.TextStyle?
    
    func body(content: Content) -> some View {
        if let size = size {
            content.font(.custom("04b03", size: size))
        } else if let textStyle = textStyle {
#if os(macOS)
            let fontSize = NSFont.preferredFont(forTextStyle: textStyle.toNSFontTextStyle()).pointSize
#else
            let fontSize = UIFont.preferredFont(forTextStyle: textStyle.toUIFontTextStyle()).pointSize
#endif
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
#if os(macOS)
    func toNSFontTextStyle() -> NSFont.TextStyle {
        switch self {
        case .largeTitle: return .title1
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
#elseif os(tvOS)
    func toUIFontTextStyle() -> UIFont.TextStyle {
        switch self {
        case .extraLargeTitle: return .extraLargeTitle
        case .extraLargeTitle2: return .extraLargeTitle2
        case .largeTitle: return .title1
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
#else
    func toUIFontTextStyle() -> UIFont.TextStyle {
        switch self {
        case .extraLargeTitle: return .extraLargeTitle
        case .extraLargeTitle2: return .extraLargeTitle2
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
#endif
}
