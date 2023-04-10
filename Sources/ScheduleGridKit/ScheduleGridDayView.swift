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
	@Binding var selectedEvent: DayInfo.EventInfo?
	let eventBuilder: EventViewBuilder
	let headerBuilder: DayHeaderBuilder

	@Environment(\.minuteHeight) var minuteHeight
	@Environment(\.startHour) var startHour
	@Environment(\.endHour) var endHour
	@Environment(\.hourLabelHeight) var hourLabelHeight
	@Environment(\.roundToNearestMinute) var roundToNearestMinute
	@Environment(\.newEventDuration) var newEventDuration
	@Environment(\.dropHandler) var dropHandler
	@Environment(\.createNewItemHandler) var createNewItemHandler
	@State var frame: CGRect?
	@State private var longPressLocation: CGPoint?
	@State private var longPressTimer: Timer?
	let longPressDuration = 1.0
	
	init(day: DayInfo, proposedDropItem: Binding<DayInfo.EventInfo?>, proposedDropDay: Binding<DayInfo?>, conflicts: [DayInfo.EventInfo] = [], selectedEvent: Binding<DayInfo.EventInfo?>, headerBuilder: @escaping DayHeaderBuilder, eventBuilder: @escaping EventViewBuilder) {
		self.day = day
		_proposedDropItem = proposedDropItem
		_proposedDropDay = proposedDropDay
		_selectedEvent = selectedEvent
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
				if day != self.day { day.remove(event: event) }
				return dropHandler(event, nil, DateInterval(start: targetDate, duration: info.eventInfo.duration))
			} else if let item = dropped as? DroppableScheduleItem {
				return dropHandler(nil, item, newInterval)
			}
			return false
		}
		//.gesture(createNewItemGesture)
		.positionedLongPressGesture { pt in
			print("Long pressed at \(pt)")
			guard let frame, let minute = minuteOffset(for: pt.y, in: frame), let createNewItemHandler else { return }
			
			let start = day.date.midnight.addingTimeInterval(minute * 60)
			createNewItemHandler(start, false)
		}
	}
	
	func clearDrag() {
		if proposedDropDay == day {
			proposedDropDay = nil
			proposedDropItem = nil
		}
	}
	
	var createNewItemGesture: some Gesture {
		DragGesture(minimumDistance: 0, coordinateSpace: .local)
			.onChanged { info in
				if longPressLocation == nil {
					longPressLocation = info.location
					longPressTimer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { _ in
						guard let offset = longPressLocation?.y, let frame, let minute = minuteOffset(for: offset, in: frame), let createNewItemHandler else { return }
						
						let start = day.date.midnight.addingTimeInterval(minute * 60)
						createNewItemHandler(start, false)
						longPressTimer = nil
					}
				}
				
				if info.translation.largestDimension > 10 { longPressTimer?.invalidate() }
			}
			.onEnded { _ in
				longPressTimer?.invalidate()
				longPressTimer = nil
				longPressLocation = nil
			}
	}
}

extension View {
	func positionedLongPressGesture(duration: TimeInterval = 1.0, completion: @escaping (CGPoint) -> Void) -> some View {
		self
			.background {
				PositionedLongPressGesture(duration: duration, completion: completion)
			}
	}
}

struct PositionedLongPressGesture: View {
	@State private var location: CGPoint?
	@State private var timer: Timer?
	let longPressDuration: TimeInterval
	var completion: (CGPoint) -> Void

	init(duration: TimeInterval = 1.0, completion: @escaping (CGPoint) -> Void) {
		self.longPressDuration = duration
		self.completion = completion
	}
	
	var body: some View {
		Color.clear
			.contentShape(Rectangle())
			.gesture(
				DragGesture(minimumDistance: 0, coordinateSpace: .local)
					.onChanged { info in
						if location == nil {
							location = info.location
							timer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { _ in
								if let location { completion(location) }
								timer = nil
							}
						}
						
						if info.translation.largestDimension > 10 { timer?.invalidate() }
					}
					.onEnded { _ in
						timer?.invalidate()
						timer = nil
						location = nil
					}

			)
	}
}
