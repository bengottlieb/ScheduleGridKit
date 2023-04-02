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
		var events = day.events
		if proposedDropDay == day, let event = proposedDropItem { events.append(event) }
		return events
	}
	
	@ViewBuilder func viewForEvent(event: DayInfo.EventInfo) -> some View {
		let isConflicted = conflicts.contains(event)
		builder(day, event, isConflicted)
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
