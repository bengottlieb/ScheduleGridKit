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
	@Environment(\.roundToNearestMinute) var roundToNearestMinute
	@State var frame: CGRect?

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
		@Environment(\.hourCycle) var hourCycle
		let hour: Int
		
		var displayHour: Int {
			if hourCycle == .zeroToTwentyThree { return hour }
			if hourCycle == .oneToTwentyFour { return hour + 1 }
			let displayed = hour % 12
			if displayed == 0 { return hourCycle == .oneToTwelve ? 12 : 0 }
			return hourCycle == .oneToTwelve ? displayed : displayed - 1
		}

		var body: some View {
			Text("\(displayHour)")
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
