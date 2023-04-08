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
		
		@State private var initialEvent: DayInfo.EventInfo?
		private var initialEnd: TimeInterval { initialEvent?.end.timeInterval ?? 0 }

		var body: some View {
			Rectangle()
				.fill(Color.white.opacity(0.01))
				.frame(height: 10)
				.gesture(dragGesture)
		}
		
		var dragGesture: some Gesture {
			DragGesture(minimumDistance: 3, coordinateSpace: .global).onChanged { action in
				if initialEvent == nil {
					initialEvent = day.event(withID: event.id) ?? event
				}
				let granularity = 15.0
				
				if top {
					let newStartY = (TimeInterval(initialEvent!.start.timeInterval.minutes) * minuteHeight) + action.translation.height
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
					
					if roundedEnd <= (initialEvent!.start.timeInterval + granularity * .minute) { return }
					let newDuration = roundedEnd - initialEvent!.start.timeInterval
					let range = Date.TimeRange(start: Date.Time(timeInterval: initialEvent!.start.timeInterval), duration: newDuration)
					day.setTime(range, for: event)
				}
			}
			.onEnded { ended in
				initialEvent = nil
				guard let final = day.event(withID: event.id) else { return }
				day.finishedResizing(event, to: final)
			}
		}
	}
}
