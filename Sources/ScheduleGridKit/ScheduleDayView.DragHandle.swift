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
		private var initialEnd: TimeInterval { initialStart + initialDuration }

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
				let granularity = 15.0
				
				if top {
					let newStartY = (TimeInterval(initialStart.minutes) * minuteHeight) + action.translation.height
					let newStartMinute = newStartY / minuteHeight
					let roundedStart = round(newStartMinute / granularity) * granularity
					let endTime = (TimeInterval(initialEnd.minutes) * minuteHeight)
					let endLimit = endTime - granularity * minuteHeight

					if roundedStart >= endLimit { return }
					let newDuration = (endTime - roundedStart) * .minute
					
					let range = Date.TimeRange(startMinute: Int(roundedStart), duration: newDuration)
					print("\(range) newStartY: \(newStartY), roundedStart: \(roundedStart), newDuration: \(newDuration)")
					day.setTime(range, for: event)
				} else {
					let newEndY = (TimeInterval(initialEnd.minutes) * minuteHeight) + action.translation.height
					let newEndMinutes = newEndY / minuteHeight
					let roundedEnd = (round(newEndMinutes / granularity) * granularity) * .minute
					
					if roundedEnd <= (initialStart + granularity * .minute) { return }
					let newDuration = roundedEnd - initialStart
					let range = Date.TimeRange(start: event.start, duration: newDuration)
					day.setTime(range, for: event)
				}
			}
			.onEnded { ended in
				initialDuration = 0
				print("Ended \(day.event(withID: event.id)!.range)")
			}
		}
	}
}
