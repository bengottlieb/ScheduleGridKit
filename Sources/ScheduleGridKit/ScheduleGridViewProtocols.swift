//
//  ScheduleViewProtocols.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/30/23.
//

import SwiftUI
import Suite

public protocol ScheduleGridDayInfo: Identifiable, ObservableObject, Equatable {
	associatedtype EventInfo: ScheduleGridEventInfo
	var events: [EventInfo] { get }
	var date: Date { get }

	func conflicts(for proposedEvent: EventInfo, on day: Self) -> [EventInfo]
	func remove(event: EventInfo)
	func proposedEvent(from info: DroppableScheduleItem, at interval: DateInterval) -> EventInfo?
	func movedEvent(from event: EventInfo, to interval: DateInterval) -> EventInfo?
	func setTime(_ range: Date.TimeRange, for event: EventInfo)
	func finishedResizing(_ start: EventInfo, to final: EventInfo)
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


public protocol ScheduleGridEventInfo: Identifiable, Hashable, Equatable {
	var id: String { get }
	var sourceID: String { get }
	var start: Date.Time { get }
	var duration: TimeInterval { get }
	var backgroundColor: Color { get }
	var foregroundColor: Color { get }
	var title: String { get }
	var isAllDay: Bool { get }
	var canAdjustTime: Bool { get }
}

extension ScheduleGridEventInfo {
	var end: Date.Time { range.end }
	var range: Date.TimeRange { Date.TimeRange(start: start, duration: duration) }
	
	func overlaps(with other: Self, tolerance: TimeInterval = 0) -> Bool {
		guard let overlap = range.intersection(with: other.range) else { return false }
		
		return overlap.duration > tolerance
	}
}

extension Array where Element: ScheduleGridEventInfo {
	func overlaps(with item: Element, tolerance: TimeInterval = 0) -> Bool {
		for element in self {
			if element.overlaps(with: item, tolerance: tolerance) { return true }
		}
		return false
	}
}

public protocol DeletableScheduleGridEvent {
	func delete(from: some ScheduleGridDayInfo)
}

public protocol ContextMenuProvidingScheduleGridEvent {
	func contextMenu(from: some ScheduleGridDayInfo) -> AnyView
}

