//
//  ScheduleDayView.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/13/23.
//

import Suite

struct ScheduleDayView<DayInfo: ScheduleGridDayInfo, EventView: View, DayHeaderView: View>: ScheduleView, Equatable {
	typealias EventViewBuilder = ScheduleGridView<DayInfo, EventView, DayHeaderView>.ScheduleEventViewBuilder
	typealias DayHeaderBuilder = ScheduleGridView<DayInfo, EventView, DayHeaderView>.ScheduleDayHeaderBuilder

	@ObservedObject var day: DayInfo
	var conflicts: [DayInfo.EventInfo]
	@Binding var proposedDropItem: DayInfo.EventInfo?
	@Binding var proposedDropDay: DayInfo?
	@Binding var selectedEvent: DayInfo.EventInfo?
	let eventBuilder: EventViewBuilder
	let headerBuilder: DayHeaderBuilder
	var shrinkOverlappingEvents = true
	
	static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.conflicts == rhs.conflicts && lhs.day == rhs.day
	}

	@Environment(\.minuteHeight) var minuteHeight
	@Environment(\.startHour) var startHour
	@Environment(\.endHour) var endHour
	@Environment(\.hourLabelHeight) var hourLabelHeight
	@Environment(\.roundToNearestMinute) var roundToNearestMinute
	@Environment(\.newEventDuration) var newEventDuration
	@Environment(\.dropHandler) var dropHandler
	@Environment(\.createNewItemHandler) var createNewItemHandler
	@State var frame: CGRect?
	@State private var longPressLocation: CGPoint?
	@State private var longPressTimer: Timer?
	let longPressDuration = 1.0
	
	init(day: DayInfo, proposedDropItem: Binding<DayInfo.EventInfo?>, proposedDropDay: Binding<DayInfo?>, conflicts: [DayInfo.EventInfo] = [], selectedEvent: Binding<DayInfo.EventInfo?>, headerBuilder: @escaping DayHeaderBuilder, eventBuilder: @escaping EventViewBuilder) {
		self.day = day
		_proposedDropItem = proposedDropItem
		_proposedDropDay = proposedDropDay
		_selectedEvent = selectedEvent
		self.conflicts = conflicts
		self.headerBuilder = headerBuilder
		self.eventBuilder = eventBuilder
	}
	
	var body: some View {
		ZStack(alignment: .top) {
			Color.clear
			
			if shrinkOverlappingEvents {
				ForEach(eventGroups) { group in
					ForEach(group.events) { event in
						viewForEvent(event: event)
					}
				}
			} else {
				ForEach(events) { event in
					viewForEvent(event: event)
				}
			}
			
		}
		.frame(height: totalDayHeight + hourLabelHeight)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background {
			ScheduleHoursView(showHours: false)
				.padding(paddingDueToHourLabel)
		}
		.reportGeometry(frame: $frame)
		.positionedLongPressGesture { pt in
			guard let frame, let minute = minuteOffset(for: pt.y, in: frame), let createNewItemHandler else { return }

			let start = day.date.midnight.addingTimeInterval(minute * 60)
			createNewItemHandler.contents(start.day, start.time)
		}
		.makeDropTarget(types: [DraggedEventInfo.dragType], hover: { type, dropped, point in
			guard let point, var minute = minutesFromMidnight(for: point.y) else {
				clearDrag()
				return false
			}

			let duration = (dropped as? DraggedEventInfo)?.eventInfo.duration ?? newEventDuration
			minute -= Int(duration / 120)
			let targetDate = day.date.dateBySetting(time: Date.Time(timeInterval: TimeInterval(minute) * 60))
			let newInterval = DateInterval(start: targetDate, duration: newEventDuration)

			if let info = dropped as? DroppableScheduleItem, let proposed = day.proposedEvent(from: info, at: newInterval) {
				proposedDropItem = proposed
				proposedDropDay = day
				return false
			}

			if let info = dropped as? DraggedEventInfo, let current = info.eventInfo as? DayInfo.EventInfo, let proposed = day.movedEvent(from: current, to: newInterval)  {
				proposedDropItem = proposed
				proposedDropDay = day
			} else {
				clearDrag()
			}
			return false
		}) { type, dropped, point in
			proposedDropItem = nil

			guard var start = minutesFromMidnight(for: point.y) else { return false }
			let duration = (dropped as? DraggedEventInfo)?.eventInfo.duration ?? newEventDuration
			start -= Int(duration / 120)
			let targetDate = day.date.dateBySetting(time: Date.Time(timeInterval: TimeInterval(start) * 60))
			let newInterval = DateInterval(start: targetDate, duration: newEventDuration)
			clearDrag()

			if let info = dropped as? DraggedEventInfo, let day = info.day as? DayInfo, let event = info.eventInfo as? DayInfo.EventInfo {
				if day != self.day { day.remove(event: event) }
				return dropHandler?.contents(event, nil, DateInterval(start: targetDate, duration: info.eventInfo.duration)) ?? false
			} else if let item = dropped as? DroppableScheduleItem {
				return dropHandler?.contents(nil, item, newInterval) ?? false
			}
			return false
		}
	}
	
	func clearDrag() {
		if proposedDropDay == day {
			proposedDropDay = nil
			proposedDropItem = nil
		}
	}
}
