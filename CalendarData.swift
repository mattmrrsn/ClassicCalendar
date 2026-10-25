import Foundation

struct CalendarEvent: Codable, Identifiable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let allDay: Bool
    let colorHex: String
}

enum CalendarStore {
    static let group = "group.com.example.classiccalendar"
    static let key = "todayEvents"
    static func save(_ events: [CalendarEvent]) {
        guard let defaults = UserDefaults(suiteName: group), let data = try? JSONEncoder().encode(events) else { return }
        defaults.set(data, forKey: key)
    }
    static func load() -> [CalendarEvent] {
        guard let data = UserDefaults(suiteName: group)?.data(forKey: key), let events = try? JSONDecoder().decode([CalendarEvent].self, from: data) else { return [] }
        return events
    }
}
