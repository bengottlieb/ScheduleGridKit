//
//  ScheduleViewProtocols.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/30/23.
//

import SwiftUI

public protocol ScheduleViewEventInfo: Identifiable, Hashable, Equatable {
	var id: String { get }
	var start: Date.Time { get }
	var duration: TimeInterval { get }
	var backgroundColor: Color { get }
	var foregroundColor: Color { get }
	var title: String { get }
}

public protocol DeletableScheduleViewEvent {
	func delete()
}

public protocol ScheduleViewDayInfo: Identifiable, ObservableObject, Equatable {
	associatedtype EventInfo: ScheduleViewEventInfo
	var events: [EventInfo] { get }
	var date: Date { get }
	
	func conflicts(for proposedEvent: EventInfo, on day: Self) -> [EventInfo]
	func remove(event: EventInfo)
	func proposedEvent(from info: DroppableScheduleItem, at interval: DateInterval) -> EventInfo?
}

extension Array where Element: ScheduleViewDayInfo {
	subscript(date: Date) -> Element? {
		for item in self {
			if item.date.isSameDay(as: date) { return item }
		}
		return nil
	}
}
