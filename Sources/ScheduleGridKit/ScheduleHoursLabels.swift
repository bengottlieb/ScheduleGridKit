//
//  ScheduleHoursLabels.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/15/23.
//

import SwiftUI

struct ScheduleHoursLabels: ScheduleView {
	@Environment(\.minuteHeight) var minuteHeight
	@Environment(\.startHour) var startHour
	@Environment(\.endHour) var endHour
	@Environment(\.hourLabelHeight) var hourLabelHeight
	@Environment(\.roundToNearestMinute) var roundToNearestMinute

	@State var frame: CGRect?
	
	var body: some View {
		Color.clear
		.frame(height: totalDayHeight + hourLabelHeight)
		.frame(maxWidth: 30, alignment: .leading)
		.background {
			ScheduleHoursView(showHours: true)
				.padding(paddingDueToHourLabel)
		}
		.background {
			GeometryReader { geo in
				Color.clear
					.onAppear { frame = geo.frame(in: .global) }
			}
		}
	}
}

