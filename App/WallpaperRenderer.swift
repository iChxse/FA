import UIKit

/// Draws a quote onto a wallpaper so it shows up large on the lock screen.
/// Text sits in the lower part of the screen, clear of the clock and lock screen widgets.
enum WallpaperRenderer {
    static func render(_ wallpaper: Wallpaper, quote: Quote?) -> Data? {
        guard let image = UIImage(contentsOfFile: wallpaper.url.path) else { return nil }
        guard let quote else { return image.jpegData(compressionQuality: 0.92) }

        let size = image.size
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let rendered = UIGraphicsImageRenderer(size: size, format: format).image { context in
            image.draw(in: CGRect(origin: .zero, size: size))

            // Soft scrim behind the text so it reads on light wallpapers too.
            let scrimRect = CGRect(x: 0, y: size.height * 0.5, width: size.width, height: size.height * 0.5)
            let colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.45).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: scrimRect.minY),
                    end: CGPoint(x: 0, y: scrimRect.maxY),
                    options: []
                )
            }

            let margin = size.width * 0.1
            let textWidth = size.width - margin * 2
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            paragraph.lineSpacing = size.width * 0.012

            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.35)
            shadow.shadowBlurRadius = size.width * 0.01

            let quoteSize = size.width * 0.055
            let systemFont = UIFont.systemFont(ofSize: quoteSize, weight: .semibold)
            let quoteFont = systemFont.fontDescriptor.withDesign(.serif).map { UIFont(descriptor: $0, size: quoteSize) } ?? systemFont
            let body = NSAttributedString(string: "\u{201C}\(quote.text)\u{201D}", attributes: [
                .font: quoteFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph,
                .shadow: shadow,
            ])
            let author = NSAttributedString(string: "\n\n\u{2014} \(quote.author)", attributes: [
                .font: UIFont.systemFont(ofSize: size.width * 0.034, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85),
                .paragraphStyle: paragraph,
                .shadow: shadow,
            ])
            let text = NSMutableAttributedString(attributedString: body)
            text.append(author)

            let bounds = text.boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            // Centered around 68% of the height: below widgets, above the flashlight and camera buttons.
            let originY = size.height * 0.68 - bounds.height / 2
            text.draw(with: CGRect(x: margin, y: originY, width: textWidth, height: bounds.height),
                      options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        }
        return rendered.jpegData(compressionQuality: 0.92)
    }
}
