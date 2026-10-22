import SwiftUI
import WidgetKit

struct QuoteWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FAQuote", provider: RotationProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Quote")
        .description("A new quote on your lock screen throughout the day.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium])
    }
}

struct QuoteWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RotationEntry

    var body: some View {
        content
            .widgetURL(URL(string: "fa://quote/\(entry.quote?.id ?? "")"))
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder
    private var content: some View {
        if let quote = entry.quote {
            switch family {
            case .accessoryInline:
                Text("\u{201C}\(quote.text)\u{201D}")
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 1) {
                    Text(quote.text)
                        .font(.system(.body, design: .serif))
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                    Text(quote.author)
                        .font(.caption2)
                        .widgetAccentable()
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            default:
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(quote.text)
                        .font(.system(family == .systemSmall ? .subheadline : .title3, design: .serif))
                        .minimumScaleFactor(0.6)
                    Spacer(minLength: 0)
                    Text("\u{2014} \(quote.author)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            Text("Open FA to load quotes")
        }
    }

    @ViewBuilder
    private var background: some View {
        switch family {
        case .accessoryInline, .accessoryRectangular, .accessoryCircular:
            Color.clear
        default:
            LinearGradient(colors: [Color(red: 0.37, green: 0.23, blue: 0.55), Color(red: 0.94, green: 0.50, blue: 0.50)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

#Preview(as: .accessoryRectangular) {
    QuoteWidget()
} timeline: {
    RotationEntry.sample
}
