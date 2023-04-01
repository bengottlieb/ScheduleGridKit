//
//  ScheduleDay.EventBubble.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/15/23.
//

import SwiftUI
import FireSpotter

public struct EventBubble<DayInfo: ScheduleViewDayInfo>: View {
	let eventInfo: DayInfo.EventInfo
	let day: DayInfo
	let isConflicted: Bool
	
	let cornerRadius = 10.0
	public var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: cornerRadius)
				.fill(eventInfo.backgroundColor)
			
			HStack {
				Text(eventInfo.start.hourMinuteString)
				Spacer()
				Text(eventInfo.title)
				Spacer()
			}
			.padding(.horizontal)
			.foregroundColor(eventInfo.foregroundColor)
			.font(.caption)
		}
		.makeDraggable(type: DraggedEventInfo.dragType, object: dragInfo)
		.contextMenu {
			Button("Edit") { }
			Button("Delete", role: .destructive) { delete() }
				.disabled(!(eventInfo is DeletableScheduleViewEvent))
		} preview: {
			Text("Preview This!")
		}
		
		if isConflicted {
			RoundedRectangle(cornerRadius: cornerRadius)
				.stroke(Color.red, lineWidth: 10)
		}
	}
	
	func delete() {
		(eventInfo as? DeletableScheduleViewEvent)?.delete()
	}
	
	var dragInfo: DraggedEventInfo {
		.init(day: day, eventInfo: eventInfo)
	}
}


public struct DraggedEventInfo {
	public static let dragType = "DraggedEventInfo"
	public let day: any ScheduleViewDayInfo
	public let eventInfo: any ScheduleViewEventInfo
}
