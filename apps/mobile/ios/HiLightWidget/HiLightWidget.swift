import WidgetKit
import SwiftUI

/// Home-screen widget. Add this folder as a Widget Extension target named
/// HiLightWidget. Do not compile this file into the Runner target.
private let suiteName = "group.com.muslima.hilight"

struct QuoteEntry: TimelineEntry {
  let date: Date
  let quote: String
  let due: Int
}

struct QuoteProvider: TimelineProvider {
  func placeholder(in context: Context) -> QuoteEntry {
    QuoteEntry(date: Date(), quote: "Save a highlight.", due: 0)
  }

  func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
    completion(load())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
    let entry = load()
    let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
    completion(Timeline(entries: [entry], policy: .after(next)))
  }

  private func load() -> QuoteEntry {
    let defaults = UserDefaults(suiteName: suiteName)
    let quote = defaults?.string(forKey: "hilight.quote") ?? ""
    let due = defaults?.integer(forKey: "hilight.due") ?? 0
    return QuoteEntry(date: Date(), quote: quote.isEmpty ? "Save a highlight." : quote, due: due)
  }
}

struct QuoteWidgetView: View {
  var entry: QuoteEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Quote of the day")
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(entry.quote)
        .font(.body)
        .lineLimit(4)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding()
  }
}

struct DueWidgetView: View {
  var entry: QuoteEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Cards due")
        .font(.caption)
        .foregroundStyle(.secondary)
      Text("\(entry.due)")
        .font(.largeTitle)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding()
  }
}

struct QuoteWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "QuoteOfDay", provider: QuoteProvider()) { entry in
      QuoteWidgetView(entry: entry)
    }
    .configurationDisplayName("Quote of the day")
    .description("A highlight from your library.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct DueWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "CardsDue", provider: QuoteProvider()) { entry in
      DueWidgetView(entry: entry)
    }
    .configurationDisplayName("Cards due")
    .description("How many review cards are waiting.")
    .supportedFamilies([.systemSmall])
  }
}

@main
struct HiLightWidgets: WidgetBundle {
  var body: some Widget {
    QuoteWidget()
    DueWidget()
  }
}
