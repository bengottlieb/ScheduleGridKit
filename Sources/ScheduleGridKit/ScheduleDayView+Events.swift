//
//  ScheduleDayView+Dragging.swift
//  ClassMap
//
//  Created by Ben Gottlieb on 4/1/23.
//

import SwiftUI

extension ScheduleDayView {
	func delete(event: DayInfo.EventInfo) {
		(event as? DeletableScheduleGridEvent)?.delete()
	}
	
	func dragInfo(for event: DayInfo.EventInfo) -> DraggedEventInfo {
		.init(day: day, eventInfo: event)
	}

	var events: [DayInfo.EventInfo] {
		var events = day.events.filter { !$0.isAllDay }
		if proposedDropDay == day, let event = proposedDropItem { events.append(event) }
		return events
	}
	
	@ViewBuilder func viewForEvent(event: DayInfo.EventInfo) -> some View {
		let isConflicted = conflicts.contains(event)
		ZStack {
			eventBuilder(day, event, isConflicted)
			if event.canAdjustTime {
				VStack {
					if height(forMinutes: event.duration.minutes) > 50 {		// only show the top handle if it's long enough duration
						DragHandle(top: true, day: day, event: event, minuteHeight: minuteHeight)
					}
					Spacer()
					DragHandle(top: false, day: day, event: event, minuteHeight: minuteHeight)
				}
			}
		}
		.frame(height: height(forMinutes: Int(event.duration / .minute)))
		.offset(y: offset(ofMinutes: Int(event.start.timeInterval / .minute)))
		.makeDraggable(type: DraggedEventInfo.dragType, object: dragInfo(for: event), hideWhenDragging: true)
		.contextMenu {
			Button("Edit") { }
			Button("Delete", role: .destructive) { delete(event: event) }
				.disabled(!(event is DeletableScheduleGridEvent))
		} preview: {
			Text("Preview This!")
		}
	}
}



public struct DraggedEventInfo {
	public static let dragType = "DraggedEventInfo"
	public let day: any ScheduleGridDayInfo
	public let eventInfo: any ScheduleGridEventInfo
}
