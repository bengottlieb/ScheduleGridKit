//
//  ScheduleDayView.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/13/23.
//

import SwiftUI
import FireSpotter

public struct ScheduleDayView<DayInfo: ScheduleViewDayInfo, EventView: View>: ScheduleView {
	@ObservedObject var day: DayInfo
	private var conflicts: [DayInfo.EventInfo]
	@Binding var proposedDropItem: DayInfo.EventInfo?
	@Binding var proposedDropDay: DayInfo?
	let builder: ScheduleContainer<DayInfo, EventView>.ScheduleEventViewBuilder

	
	@Environment(\.minuteHeight) var minuteHeight
	@Environment(\.startHour) var startHour
	@Environment(\.endHour) var endHour
	@Environment(\.hourLabelHeight) var hourLabelHeight
	@Environment(\.roundToNearestMinute) var roundToNearestMinute
	@Environment(\.newEventDuration) var newEventDuration
	@Environment(\.dropHandler) var dropHandler
	
	@State private var frame: CGRect?
	@State private var dragStartMinute: Int?
	
	init(day: DayInfo, proposedDropItem: Binding<DayInfo.EventInfo?>, proposedDropDay: Binding<DayInfo?>, conflicts: [DayInfo.EventInfo] = [], builder: @escaping ScheduleContainer<DayInfo, EventView>.ScheduleEventViewBuilder) {
		self.day = day
		_proposedDropItem = proposedDropItem
		_proposedDropDay = proposedDropDay
		self.conflicts = conflicts
		self.builder = builder
	}
	
	var events: [DayInfo.EventInfo] {
		var events = day.events
		if proposedDropDay == day, let event = proposedDropItem {
			events.append(event)
		}
		return events
	}
	
	public var body: some View {
		ZStack(alignment: .top) {
			Color.clear
			
			ForEach(events) { event in
				let isConflicted = conflicts.contains(event)
				builder(day, event, isConflicted)
//				EventBubble(eventInfo: event, day: day, isConflicted: isConflicted)
					.frame(height: height(forMinutes: Int(event.duration / .minute)))
					.offset(y: offset(ofMinutes: Int(event.start.timeInterval / .minute)))
			}
			
		}
		.frame(height: totalDayHeight + hourLabelHeight)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background {
			ScheduleHoursView(showHours: false)
				.padding(paddingDueToHourLabel)
		}
		.background {
			GeometryReader { geo in
				Color.clear
					.onAppear { frame = geo.frame(in: .global) }
			}
		}
		.makeDropTarget(types: [DraggedEventInfo.dragType], hover: { type, dropped, point in
			guard let point, let minute = minutesFromMidnight(for: point.y) else {
				clearDrag()
				return false
			}
			dragStartMinute = minute
			
			let targetDate = day.date.dateBySetting(time: Date.Time(timeInterval: TimeInterval(minute) * 60))
			let newInterval = DateInterval(start: targetDate, duration: newEventDuration)
			
			if let info = dropped as? DroppableScheduleItem, let proposed = day.proposedEvent(from: info, at: newInterval) {
				proposedDropItem = proposed
				proposedDropDay = day
				return false
			}
			
			clearDrag()
			return false
		}) { type, dropped, point in
			proposedDropItem = nil
			
			guard let start = dragStartMinute else { return false }
			dragStartMinute = nil
			let targetDate = day.date.dateBySetting(time: Date.Time(timeInterval: TimeInterval(start) * 60))
			let newInterval = DateInterval(start: targetDate, duration: newEventDuration)
			
			if let info = dropped as? DraggedEventInfo, let day = info.day as? DayInfo, let event = info.eventInfo as? DayInfo.EventInfo {
				day.remove(event: event)
				return dropHandler(event, nil, newInterval)
			} else if let item = dropped as? DroppableScheduleItem {
				
				return dropHandler(nil, item, newInterval)
			}
			return false
		}
	}
	
	func clearDrag() {
		dragStartMinute = nil
		
		if proposedDropDay == day {
			proposedDropDay = nil
			proposedDropItem = nil
		}
	}
	
	func minutesFromMidnight(for y: CGFloat) -> Int? {
		guard let frame, let minute = minuteOffset(for: y, in: frame) else { return nil }
		
		
		return Int(round(minute / roundToNearestMinute) * roundToNearestMinute)
	}
}
