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
}

extension Array where Element: ScheduleGridDayInfo {
	subscript(date: Date) -> Element? {
		for item in self {
			if item.date.isSameDay(as: date) { return item }
		}
		return nil
	}
}
