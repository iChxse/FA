import SwiftUI
import WidgetKit

struct WordWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "FAWord", provider: RotationProvider()) { entry in
            WordWidgetView(entry: entry)
        }
        .configurationDisplayName("Word")
        .description("Learn a new word and its definition from your lock screen.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium])
    }
}

struct WordWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RotationEntry

    var body: some View {
        content
            .widgetURL(URL(string: "fa://word/\(entry.word?.id ?? "")"))
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder
    private var content: some View {
        if let word = entry.word {
            switch family {
            case .accessoryInline:
                Text("\(word.word): \(word.definition)")
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 1) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(word.word)
                            .font(.system(.headline, design: .serif))
                            .widgetAccentable()
                        Text(word.partOfSpeech)
                            .font(.caption2.italic())
                    }
                    Text(word.definition)
                        .font(.caption)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            default:
                VStack(alignment: .leading, spacing: 6) {
                    Text(word.word)
                        .font(.system(family == .systemSmall ? .title2 : .title, design: .serif).weight(.semibold))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text(word.partOfSpeech)
                        .font(.caption.italic())
                        .foregroundStyle(.white.opacity(0.75))
                    Text(word.definition)
                        .font(family == .systemSmall ? Font.caption : Font.subheadline)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            Text("Open FA to load words")
        }
    }

    @ViewBuilder
    private var background: some View {
        switch family {
        case .accessoryInline, .accessoryRectangular, .accessoryCircular:
            Color.clear
        default:
            LinearGradient(colors: [Color(red: 0.03, green: 0.16, blue: 0.24), Color(red: 0.25, green: 0.70, blue: 0.67)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

#Preview(as: .accessoryRectangular) {
    WordWidget()
} timeline: {
    RotationEntry.sample
}
