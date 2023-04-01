//
//  ScheduleHoursView.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/14/23.
//

import SwiftUI

public struct ScheduleHoursView: ScheduleView {
	let showHours: Bool
	
	@Environment(\.minuteHeight) var minuteHeight
	@Environment(\.startHour) var startHour
	@Environment(\.endHour) var endHour
	@Environment(\.hourLabelHeight) var hourLabelHeight

	public init(showHours: Bool = true) {
		self.showHours = showHours
	}
	
	public var body: some View {
		ZStack(alignment: .top) {
			Color.clear
			ForEach(startHour...endHour, id: \.self) { hour in
				HStack {
					if showHours {
						HourLabel(hour: hour)
					} else {
						Rectangle()
							.fill(Color.gray)
							.frame(height: 1)
							.frame(maxWidth: .infinity)
					}
				}
				.frame(height: hourLabelHeight)
				.offset(x: 0, y: offset(for: hour) - paddingDueToHourLabel.top)
			}
		}
	}

	func offset(for hour: Int) -> CGFloat {
		CGFloat(hour - startHour) * hourHeight
	}
	
	struct HourLabel: View {
		let hour: Int
		
		var body: some View {
			Text("\(hour)")
				.font(.system(size: 10))
		}
	}
}

struct ScheduleHoursView_Previews: PreviewProvider {
	static var previews: some View {
		ScrollView {
			ScheduleHoursView()
		}
		.frame(width: 200)
	}
}
