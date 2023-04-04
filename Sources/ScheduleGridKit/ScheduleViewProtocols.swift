//
//  ScheduleViewProtocols.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/30/23.
//

import SwiftUI

public protocol ScheduleGridEventInfo: Identifiable, Hashable, Equatable {
	var id: String { get }
	var start: Date.Time { get }
	var duration: TimeInterval { get }
	var backgroundColor: Color { get }
	var foregroundColor: Color { get }
	var title: String { get }
	var isAllDay: Bool { get }
	var canAdjustTime: Bool { get }
}

extension ScheduleGridEventInfo {
	var range: Date.TimeRange { Date.TimeRange(start: start, duration: duration) }
}

public protocol DeletableScheduleGridEvent {
	func delete()
}

public protocol ScheduleGridDayInfo: Identifiable, ObservableObject, Equatable {
	associatedtype EventInfo: ScheduleGridEventInfo
	var events: [EventInfo] { get }
	var date: Date { get }

	func conflicts(for proposedEvent: EventInfo, on day: Self) -> [EventInfo]
	func remove(event: EventInfo)
	func proposedEvent(from info: DroppableScheduleItem, at interval: DateInterval) -> EventInfo?
	func movedEvent(from event: EventInfo, to interval: DateInterval) -> EventInfo?
	func setTime(_ range: Date.TimeRange, for event: EventInfo)
}

extension ScheduleGridDayInfo {
	func event(withID id: String) -> EventInfo? {
		events.first { $0.id == id }
	}
}

extension Array where Element: ScheduleGridDayInfo {
	subscript(date: Date) -> Element? {
		for item in self {
			if item.date.isSameDay(as: date) { return item }
		}
		return nil
	}
}
