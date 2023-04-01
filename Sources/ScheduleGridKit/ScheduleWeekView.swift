//
//  ScheduleWeekView.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/13/23.
//

import SwiftUI
import Suite

struct ScheduleWeekView<DayInfo: ScheduleViewDayInfo, EventView: View>: View {
	let days: [DayInfo]
	let builder: ScheduleContainer<DayInfo, EventView>.ScheduleEventViewBuilder
	@Binding var proposedDropItem: DayInfo.EventInfo?
	@Binding var proposedDropDay: DayInfo?
	private var conflicts: [DayInfo.EventInfo]
	
	public enum WeekendStyle { case none, startSunday, startMonday }
	
	public init(days: [DayInfo], proposedDropItem: 	Binding<DayInfo.EventInfo?>, proposedDropDay: Binding<DayInfo?>, conflicts: [DayInfo.EventInfo], builder: @escaping ScheduleContainer<DayInfo, EventView>.ScheduleEventViewBuilder) {
		self.days = days
		self.conflicts = conflicts
		_proposedDropItem = proposedDropItem
		_proposedDropDay = proposedDropDay
		self.builder = builder
	}
	
	var body: some View {
		HStack(spacing: 0) {
			ScheduleHoursLabels()
			ForEach(days) { day in
				ScheduleDayView(day: day, proposedDropItem: $proposedDropItem, proposedDropDay: $proposedDropDay, conflicts: conflicts, builder: builder)
			}
		}
	}
}
