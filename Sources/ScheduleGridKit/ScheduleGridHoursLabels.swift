//
//  ScheduleHoursLabels.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/15/23.
//

import Suite

struct ScheduleHoursLabels: ScheduleView {
	let width: CGFloat
	@Environment(\.minuteHeight) var minuteHeight
	@Environment(\.startHour) var startHour
	@Environment(\.endHour) var endHour
	@Environment(\.hourLabelHeight) var hourLabelHeight
	@Environment(\.roundToNearestMinute) var roundToNearestMinute

	@State var frame: CGRect?
	
	var body: some View {
		Color.clear
			.frame(height: totalDayHeight + hourLabelHeight)
			.frame(width: width, alignment: .leading)
			.background {
				ScheduleHoursView(showHours: true)
					.padding(paddingDueToHourLabel)
			}
			.frameReporting($frame ?? .zero)
	}
}

