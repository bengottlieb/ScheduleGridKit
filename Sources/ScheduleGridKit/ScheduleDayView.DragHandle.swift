//
//  ScheduleDayView.DragHandle.swift
//  
//
//  Created by Ben Gottlieb on 4/4/23.
//

import SwiftUI

extension ScheduleDayView {
	struct DragHandle<DayInfo: ScheduleGridDayInfo>: View {
		let top: Bool
		let day: DayInfo
		let event: DayInfo.EventInfo
		let minuteHeight: Double
		
		@State private var initialDuration: TimeInterval = 0
		@State private var initialStart: TimeInterval = 0

		var body: some View {
			Rectangle()
				.fill(Color.blue)
				.frame(height: 10)
				.gesture(dragGesture)
		}
		
		var dragGesture: some Gesture {
			DragGesture(minimumDistance: 15, coordinateSpace: .global).onChanged { action in
				if initialDuration == 0 {
					initialDuration = event.duration
					initialStart = event.start.timeInterval
				}
				let granularity = 15.0 * .minute
				let adjustment = (action.translation.height / minuteHeight) * .minute
				let delta = round(adjustment / granularity) * granularity
				
				if top {
					let newStart = initialStart + delta
					let initialEnd = initialStart + initialDuration - granularity
					if newStart >= initialEnd { return }
					
					let range = Date.TimeRange(start: Date.Time(timeInterval: newStart), duration: initialDuration - delta)
					day.setTime(range, for: event)
				} else {
					let newDuration = initialDuration + delta
					if newDuration < granularity { return }
					let range = Date.TimeRange(start: event.start, duration: newDuration)
					day.setTime(range, for: event)
				}
			}
			.onEnded { ended in
				initialDuration = 0
			}
		}
	}
}
