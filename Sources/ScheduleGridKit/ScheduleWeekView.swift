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
	let headerBuilder: DayHeaderBuilder
	let eventBuilder: EventViewBuilder
	@Binding var proposedDropItem: DayInfo.EventInfo?
	@Binding var proposedDropDay: DayInfo?
	private var conflicts: [DayInfo.EventInfo]
	@Environment(\.scheduleDaySpacing) var scheduleDaySpacing
	
	public enum WeekendStyle { case none, startSunday, startMonday }
	
	public init(days: [DayInfo], proposedDropItem: 	Binding<DayInfo.EventInfo?>, proposedDropDay: Binding<DayInfo?>, conflicts: [DayInfo.EventInfo], headerBuilder: @escaping DayHeaderBuilder, eventBuilder: @escaping EventViewBuilder) {
		self.days = days
		self.conflicts = conflicts
		_proposedDropItem = proposedDropItem
		_proposedDropDay = proposedDropDay
		self.eventBuilder = eventBuilder
		self.headerBuilder = headerBuilder
	}
	
	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 0) {
				HStack(spacing: 0) {
					ForEach(days) { day in
						headerBuilder(day)
							.frame(width: (geo.size.width - hoursWidth) / CGFloat(days.count), alignment: .center)
							.padding(.trailing, scheduleDaySpacing)
					}
				}
				.padding(.leading, hoursWidth)

				ScrollView {
					HStack(spacing: 0) {
						ScheduleHoursLabels(width: hoursWidth)
						ForEach(days) { day in
							ScheduleDayView(day: day, proposedDropItem: $proposedDropItem, proposedDropDay: $proposedDropDay, conflicts: conflicts, headerBuilder: headerBuilder, eventBuilder: eventBuilder)
								.padding(.trailing, scheduleDaySpacing)
						}
					}
				}
			}
		}
	}
}
