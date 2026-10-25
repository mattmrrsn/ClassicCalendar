import WidgetKit
import SwiftUI

struct CalendarEntry: TimelineEntry {
    let date: Date
    let events: [CalendarEvent]
}

struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry { CalendarEntry(date: Date(), events: []) }
    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) { completion(CalendarEntry(date: Date(), events: CalendarStore.load())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let now = Date()
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: now) ?? now.addingTimeInterval(1800)
        completion(Timeline(entries: [CalendarEntry(date: now, events: CalendarStore.load())], policy: .after(next)))
    }
}

struct ClassicCalendarView: View {
    let entry: CalendarEntry
    private var cal: Calendar { Calendar.current }
    private var day: Int { cal.component(.day, from: entry.date) }
    private var month: String { entry.date.formatted(.dateTime.month(.wide)) }
    private var days: [Int?] {
        guard let interval = cal.dateInterval(of: .month, for: entry.date), let range = cal.range(of: .day, in: .month, for: entry.date) else { return [] }
        let weekday = cal.component(.weekday, from: interval.start) - 1
        return Array(repeating: nil, count: weekday) + range.map { Optional($0) }
    }
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(entry.date.formatted(.dateTime.weekday(.wide)).uppercased() + " \(day)")
                        .font(.system(size: 11, weight: .semibold)).foregroundStyle(.red).lineLimit(1)
                    if entry.events.isEmpty {
                        Text("No Events Today").font(.system(size: 12)).foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(entry.events.prefix(3))) { event in
                            HStack(alignment: .top, spacing: 6) {
                                Capsule().fill(Color(hex: event.colorHex)).frame(width: 3, height: event.allDay ? 15 : 30)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title).font(.system(size: 12, weight: .medium)).lineLimit(1)
                                    if !event.allDay {
                                        Text("\(event.start.formatted(date: .omitted, time: .shortened)) – \(event.end.formatted(date: .omitted, time: .shortened))")
                                            .font(.system(size: 10)).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.8)
                                    }
                                }
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }.frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 7) {
                    Text(month).font(.system(size: 16, weight: .semibold))
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(0..<7, id: \.self) { index in
                            Text(["S","M","T","W","T","F","S"][index])
                                .font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary)
                        }
                        ForEach(Array(days.enumerated()), id: \.offset) { _, d in
                            ZStack {
                                if d == day { Circle().fill(.red).frame(width: 19, height: 19) }
                                Text(d.map(String.init) ?? " ")
                                    .font(.system(size: 10, weight: d == day ? .semibold : .regular))
                                    .foregroundStyle(d == day ? Color.white : Color.primary)
                            }.frame(height: 19)
                        }
                    }
                    Spacer(minLength: 0)
                }.frame(width: geo.size.width * 0.48, alignment: .leading)
            }.padding(12)
        }.containerBackground(.background, for: .widget)
    }
}

extension Color {
    init(hex: String) {
        let raw = Int(hex.dropFirst(), radix: 16) ?? 0x007AFF
        self.init(red: Double((raw >> 16) & 255)/255, green: Double((raw >> 8) & 255)/255, blue: Double(raw & 255)/255)
    }
}

struct ClassicCalendarWidget: Widget {
    let kind = "ClassicCalendarWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in ClassicCalendarView(entry: entry) }
            .configurationDisplayName("Classic Calendar")
            .description("Classic month view with today's events.")
            .supportedFamilies([.systemMedium])
    }
}
