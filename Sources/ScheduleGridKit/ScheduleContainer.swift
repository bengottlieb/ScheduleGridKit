//
//  ScheduleContainer.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/14/23.
//

import Suite


public typealias DropHandler = ((any ScheduleViewEventInfo)?, DroppableScheduleItem?, DateInterval) -> Bool


public struct ScheduleContainer<DayInfo: ScheduleViewDayInfo, EventView: View>: View {
	var minuteHeight: CGFloat = 1
	var startHour = 7
	var endHour = 18
	let hourLabelHeight = 14.0
	let days: [DayInfo]
	let builder: ScheduleEventViewBuilder

	public typealias ScheduleEventViewBuilder = (DayInfo, DayInfo.EventInfo, Bool) -> EventView

	@State private var proposedDropItem: DayInfo.EventInfo?
	@State private var proposedDropDay: DayInfo?
	@State private var conflicts: [DayInfo.EventInfo] = []

	public init(days: [DayInfo], minuteHeight: CGFloat = 1, startHour: Int = 7, endHour: Int = 18, builder: @escaping ScheduleEventViewBuilder) {
		self.minuteHeight = minuteHeight
		self.startHour = startHour
		self.endHour = endHour
		self.days = days
		self.builder = builder
	}
	
	public var body: some View {
		ScrollView {
			ScheduleWeekView(days: days, proposedDropItem: $proposedDropItem, proposedDropDay: $proposedDropDay, conflicts: conflicts, builder: builder)
		}
		.environment(\.minuteHeight, minuteHeight)
		.environment(\.startHour, startHour)
		.environment(\.endHour, endHour)
		.environment(\.hourLabelHeight, hourLabelHeight)
		.onChange(of: proposedDropItem) { event in checkForConflicts(with: event, on: proposedDropDay) }
		.onChange(of: proposedDropDay) { day in checkForConflicts(with: proposedDropItem, on: day) }
	}
	
	func checkForConflicts(with event: DayInfo.EventInfo?, on day: DayInfo?) {
		guard let day, let event else {
			self.conflicts = []
			return
		}
		var conflicts: [DayInfo.EventInfo] = []
		
		for d in days {
			conflicts += d.conflicts(for: event, on: day)
		}
		self.conflicts = conflicts
	}
}

public extension ScheduleContainer where EventView == ScheduleEventBubble<DayInfo> {
	init(days: [DayInfo], minuteHeight: CGFloat = 1, startHour: Int = 7, endHour: Int = 18) {
		self.init(days: days, minuteHeight: minuteHeight, startHour: startHour, endHour: endHour) { day, event, conflicted in
			ScheduleEventBubble(eventInfo: event, day: day, isConflicted: conflicted)
		}
	}

}

public extension View {
	@ViewBuilder func dateDropHandler(handler: @escaping DropHandler) -> some View {
		self
			.environment(\.dropHandler, handler)
	}
}
