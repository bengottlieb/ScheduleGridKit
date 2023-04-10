//
//  ScheduleWeekView.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/13/23.
//

import SwiftUI
import Suite

struct ScheduleWeekView<DayInfo: ScheduleGridDayInfo, EventView: View, DayHeaderView: View>: View {
	typealias EventViewBuilder = ScheduleGridView<DayInfo, EventView, DayHeaderView>.ScheduleEventViewBuilder
	typealias DayHeaderBuilder = ScheduleGridView<DayInfo, EventView, DayHeaderView>.ScheduleDayHeaderBuilder

	let days: [DayInfo]
	var hoursWidth = 30.0
	var isScrollable: Bool
	@Binding var isScrolling: Bool
	let headerBuilder: DayHeaderBuilder
	let eventBuilder: EventViewBuilder
	@Binding var proposedDropItem: DayInfo.EventInfo?
	@Binding var proposedDropDay: DayInfo?
	@Binding var selectedEvent: DayInfo.EventInfo?
	private var conflicts: [DayInfo.EventInfo]
	@Environment(\.scheduleDaySpacing) var scheduleDaySpacing
	@Environment(\.minuteHeight) var minuteHeight
	@Environment(\.createNewItemHandler) var createNewItemHandler
	
	public enum WeekendStyle { case none, startSunday, startMonday }
	
	public init(days: [DayInfo], proposedDropItem: 	Binding<DayInfo.EventInfo?>, proposedDropDay: Binding<DayInfo?>, isScrollable: Bool, isScrolling: Binding<Bool>, conflicts: [DayInfo.EventInfo], selectedEvent: Binding<DayInfo.EventInfo?>, headerBuilder: @escaping DayHeaderBuilder, eventBuilder: @escaping EventViewBuilder) {
		self.days = days
		self.conflicts = conflicts
		_proposedDropItem = proposedDropItem
		_proposedDropDay = proposedDropDay
		_selectedEvent = selectedEvent
		self.eventBuilder = eventBuilder
		self.headerBuilder = headerBuilder
		self.isScrollable = isScrollable
		_isScrolling = isScrolling
	}
	
	var body: some View {
		GeometryReader { geo in
			VStack(alignment: .leading, spacing: 0) {
				HStack(alignment: .top, spacing: 0) {
					ForEach(days) { day in
						VStack {
							headerBuilder(day)
							
							ForEach(day.events.filter { $0.isAllDay }) { event in
								eventBuilder(day, event, false)
									.frame(height: minuteHeight * 30.0)
							}
						}
						.frame(width: (geo.size.width - (hoursWidth + scheduleDaySpacing * Double(days.count - 1))) / CGFloat(days.count), alignment: .center)
						.padding(.trailing, scheduleDaySpacing)
					}
				}
				.multilineTextAlignment(.center)
				.padding(.leading, hoursWidth)

				let content = HStack(spacing: 0) {
					ScheduleHoursLabels(width: hoursWidth)
					  ForEach(days) { day in
						  ScheduleDayView(day: day, proposedDropItem: $proposedDropItem, proposedDropDay: $proposedDropDay, conflicts: conflicts, selectedEvent: $selectedEvent, headerBuilder: headerBuilder, eventBuilder: eventBuilder)
							  .padding(.trailing, scheduleDaySpacing)
					  }
				  }
				
				if isScrollable {
					ScrollView {
						ScrollCanary(isScrolling: $isScrolling)
						content
					}
				} else {
					content
				}
			}
		}
	}
}
