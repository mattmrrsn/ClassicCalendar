import SwiftUI
import EventKit
import WidgetKit

@main
struct ClassicCalendarApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}

struct ContentView: View {
    @State private var message = "Tap Sync Calendar to grant access and load events."
    private let store = EKEventStore()
    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "calendar").font(.system(size: 58)).foregroundStyle(.red)
            Text("Classic Calendar").font(.largeTitle.bold())
            Text("Your iOS 14-inspired Home Screen calendar widget.").multilineTextAlignment(.center)
            Button("Sync Calendar") { Task { await sync() } }.buttonStyle(.borderedProminent)
            Text(message).font(.footnote).multilineTextAlignment(.center)
            Text("After syncing, add the medium Classic Calendar widget to your Home Screen. Open this app to refresh events. Widget updates are managed by iOS.")
                .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.padding()
    }
    @MainActor private func sync() async {
        do {
            let granted = try await store.requestFullAccessToEvents()
            guard granted else { message = "Calendar access denied. Enable it in Settings."; return }
            let start = Calendar.current.startOfDay(for: Date())
            guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return }
            let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
            let items = store.events(matching: predicate).sorted { $0.startDate < $1.startDate }
            let mapped = items.map { event -> CalendarEvent in
                let c = UIColor(cgColor: event.calendar.cgColor)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                c.getRed(&r, green: &g, blue: &b, alpha: &a)
                return CalendarEvent(id: event.eventIdentifier ?? UUID().uuidString, title: event.title ?? "Event", start: event.startDate, end: event.endDate, allDay: event.isAllDay, colorHex: String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255)))
            }
            CalendarStore.save(mapped)
            WidgetCenter.shared.reloadAllTimelines()
            message = "Synced \(mapped.count) events for today."
        } catch { message = "Calendar access error: \(error.localizedDescription)" }
    }
}
