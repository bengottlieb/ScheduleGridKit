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
		
		if isConflicted {
			RoundedRectangle(cornerRadius: cornerRadius)
				.stroke(Color.red, lineWidth: 10)
		}
	}
}
