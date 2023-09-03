//
//  ScheduleEventBubble.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/15/23.
//

import SwiftUI

public struct ScheduleEventBubble<DayInfo: ScheduleGridDayInfo>: View {
	let eventInfo: DayInfo.EventInfo
	let day: DayInfo
	let isConflicted: Bool
	
	let cornerRadius = 10.0
	public var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: cornerRadius)
				.fill(eventInfo.backgroundColor)
			
			ViewThatFits {
				titleAndTime
				titleOnly
			}
			.padding(.horizontal)
			.foregroundColor(eventInfo.foregroundColor)
			.font(.caption)
			.tooltip(tooltipText)
		}
		
		if isConflicted {
			RoundedRectangle(cornerRadius: cornerRadius)
				.stroke(Color.red, lineWidth: 10)
		}
	}
	
	var tooltipText: String {
		let base = eventInfo.title
		
		if !eventInfo.isAllDay {
			return eventInfo.start.hourMinuteString + "-" + eventInfo.end.hourMinuteString + " " + base
		}
		return base
	}
	
	var titleOnly: some View {
		Text(eventInfo.title)
	}
	
	var titleAndTime: some View {
		HStack {
			if !eventInfo.isAllDay {
				Text(eventInfo.start.hourMinuteString)
			}
			Spacer()
			Text(eventInfo.title)
			Spacer()
		}
	}
}
