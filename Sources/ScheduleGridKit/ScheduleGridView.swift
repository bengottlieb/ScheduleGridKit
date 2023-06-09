//
//  ScheduleGridView.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/14/23.
//

import Suite


public typealias DropHandler = ((any ScheduleGridEventInfo)?, DroppableScheduleItem?, DateInterval) -> Bool
public typealias CreateNewItemHandler = (Date.Day, Date.Time?) -> Void

public struct ScheduleGridView<DayInfo: ScheduleGridDayInfo, EventView: View, DayHeaderView: View>: View {
	var minuteHeight: CGFloat = 1
	var startHour = 7
	var endHour = 18
	let hourLabelHeight = 14.0
	let hourCycle: HourMode
	let days: [DayInfo]
	let isScrollable: Bool
	let headerBuilder: ScheduleDayHeaderBuilder
	let eventBuilder: ScheduleEventViewBuilder
	@Binding var selectedEvent: DayInfo.EventInfo?
	@Binding var isScrolling: Bool

	public typealias ScheduleEventViewBuilder = (DayInfo, DayInfo.EventInfo, Bool) -> EventView
	public typealias ScheduleDayHeaderBuilder = (DayInfo) -> DayHeaderView

	@State private var proposedDropItem: DayInfo.EventInfo?
	@State private var proposedDropDay: DayInfo?
	@State private var conflicts: [DayInfo.EventInfo] = []

	public init(days: [DayInfo], minuteHeight: CGFloat = 1, startHour: Int? = nil, endHour: Int? = nil, hourCycle: HourMode? = nil, isScrollable: Bool = true, isScrolling: Binding<Bool> = .constant(false), selectedEvent: Binding<DayInfo.EventInfo?>, headerBuilder: @escaping ScheduleDayHeaderBuilder, eventBuilder: @escaping ScheduleEventViewBuilder) {
		self.minuteHeight = minuteHeight
		self.startHour = startHour ?? StartHourEnvironmentKey.defaultValue
		self.endHour = endHour ?? EndHourEnvironmentKey.defaultValue
		self.days = days
		self.headerBuilder = headerBuilder
		self.eventBuilder = eventBuilder
		self.isScrollable = isScrollable
		self.hourCycle = hourCycle ?? HourMode.current
		_isScrolling = isScrolling
		_selectedEvent = selectedEvent
	}
	
	public var body: some View {
		ScheduleWeekView(days: days, proposedDropItem: $proposedDropItem, proposedDropDay: $proposedDropDay, isScrollable: isScrollable, isScrolling: $isScrolling, conflicts: conflicts, selectedEvent: $selectedEvent, headerBuilder: headerBuilder, eventBuilder: eventBuilder)
			.environment(\.minuteHeight, minuteHeight)
			.environment(\.startHour, startHour)
			.environment(\.endHour, endHour)
			.environment(\.hourLabelHeight, hourLabelHeight)
			.environment(\.hourCycle, hourCycle)
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

public extension ScheduleGridView where EventView == ScheduleEventBubble<DayInfo>, DayHeaderView == EmptyView {
	init(days: [DayInfo], minuteHeight: CGFloat = 1, startHour: Int? = nil, endHour: Int? = nil, hourCycle: HourMode, isScrollable: Bool = true, isScrolling: Binding<Bool> = .constant(false), selectedEvent: Binding<DayInfo.EventInfo?>) {
		self.init(days: days, minuteHeight: minuteHeight, startHour: startHour, endHour: endHour, hourCycle: hourCycle, isScrollable: isScrollable, isScrolling: isScrolling, selectedEvent: selectedEvent, headerBuilder: { _ in EmptyView() }, eventBuilder: { day, event, conflicted in
			ScheduleEventBubble(eventInfo: event, day: day, isConflicted: conflicted)
		})
	}
}

public extension ScheduleGridView where EventView == ScheduleEventBubble<DayInfo> {
	init(days: [DayInfo], minuteHeight: CGFloat = 1, startHour: Int? = nil, endHour: Int? = nil, hourCycle: HourMode = .oneToTwelve, isScrollable: Bool = true, isScrolling: Binding<Bool> = .constant(false), selectedEvent: Binding<DayInfo.EventInfo?>, headerBuilder: @escaping (DayInfo) -> DayHeaderView) {
		self.init(days: days, minuteHeight: minuteHeight, startHour: startHour, endHour: endHour, hourCycle: hourCycle, isScrollable: isScrollable, isScrolling: isScrolling, selectedEvent: selectedEvent, headerBuilder: headerBuilder, eventBuilder: { day, event, conflicted in
			ScheduleEventBubble(eventInfo: event, day: day, isConflicted: conflicted)
		})
	}
}

public extension View {
	@ViewBuilder func dateDropHandler(_ id: () -> String = { "\(#file):\(#line)" }, handler: @escaping DropHandler) -> some View {
		self
			.environment(\.dropHandler, .init(contents: handler, id: id()))
	}
}
