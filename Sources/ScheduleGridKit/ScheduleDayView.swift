//
//  ScheduleDayView.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/13/23.
//

import Suite

struct ScheduleDayView<DayInfo: ScheduleGridDayInfo, EventView: View, DayHeaderView: View>: ScheduleView {
	typealias EventViewBuilder = ScheduleGridView<DayInfo, EventView, DayHeaderView>.ScheduleEventViewBuilder
	typealias DayHeaderBuilder = ScheduleGridView<DayInfo, EventView, DayHeaderView>.ScheduleDayHeaderBuilder

	@ObservedObject var day: DayInfo
	var conflicts: [DayInfo.EventInfo]
	@Binding var proposedDropItem: DayInfo.EventInfo?
	@Binding var proposedDropDay: DayInfo?
	let eventBuilder: EventViewBuilder
	let headerBuilder: DayHeaderBuilder

	@Environment(\.minuteHeight) var minuteHeight
	@Environment(\.startHour) var startHour
	@Environment(\.endHour) var endHour
	@Environment(\.hourLabelHeight) var hourLabelHeight
	@Environment(\.roundToNearestMinute) var roundToNearestMinute
	@Environment(\.newEventDuration) var newEventDuration
	@Environment(\.dropHandler) var dropHandler
	@State var frame: CGRect?
	
	init(day: DayInfo, proposedDropItem: Binding<DayInfo.EventInfo?>, proposedDropDay: Binding<DayInfo?>, conflicts: [DayInfo.EventInfo] = [], headerBuilder: @escaping DayHeaderBuilder, eventBuilder: @escaping EventViewBuilder) {
		self.day = day
		_proposedDropItem = proposedDropItem
		_proposedDropDay = proposedDropDay
		self.conflicts = conflicts
		self.headerBuilder = headerBuilder
		self.eventBuilder = eventBuilder
	}
	
	var body: some View {
		ZStack(alignment: .top) {
			Color.clear
			
			ForEach(events) { event in
				viewForEvent(event: event)
			}
			
		}
		.frame(height: totalDayHeight + hourLabelHeight)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background {
			ScheduleHoursView(showHours: false)
				.padding(paddingDueToHourLabel)
		}
		.reportGeometry(frame: $frame)
		.makeDropTarget(types: [DraggedEventInfo.dragType], hover: { type, dropped, point in
			guard let point, let minute = minutesFromMidnight(for: point.y) else {
				clearDrag()
				return false
			}
			
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
			
			guard let start = minutesFromMidnight(for: point.y) else { return false }
			let targetDate = day.date.dateBySetting(time: Date.Time(timeInterval: TimeInterval(start) * 60))
			let newInterval = DateInterval(start: targetDate, duration: newEventDuration)
			clearDrag()
			
			if let info = dropped as? DraggedEventInfo, let day = info.day as? DayInfo, let event = info.eventInfo as? DayInfo.EventInfo {
				day.remove(event: event)
				return dropHandler(event, nil, DateInterval(start: targetDate, duration: info.eventInfo.duration))
			} else if let item = dropped as? DroppableScheduleItem {
				return dropHandler(nil, item, newInterval)
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
