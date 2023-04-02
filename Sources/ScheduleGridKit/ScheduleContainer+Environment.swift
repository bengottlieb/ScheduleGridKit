//
//  ScheduleRoot+Environment.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/14/23.
//

import Suite

struct MinuteHeightEnvironmentKey: EnvironmentKey {
	static var defaultValue = 1.0
}

struct StartHourEnvironmentKey: EnvironmentKey {
	static var defaultValue = 7
}

struct DaySpacingEnvironmentKey: EnvironmentKey {
	static var defaultValue = 5.0
}

struct EndHourEnvironmentKey: EnvironmentKey {
	static var defaultValue = 18
}

struct HourLabelHeightEnvironmentKey: EnvironmentKey {
	static var defaultValue = 14.0
}

struct RoundToNearestMinuteEnvironmentKey: EnvironmentKey {
	static var defaultValue = 15.0
}

struct NewEventDurationEnvironmentKey: EnvironmentKey {
	static var defaultValue = 30.0 * 60.0
}

struct DropHandlerPreferenceKey: PreferenceKey {
	static func reduce(value: inout IDBox<DropHandler, String>?, nextValue: () -> IDBox<DropHandler, String>?) {
		value = nextValue() ?? value
	}
	
	static var defaultValue: IDBox<DropHandler, String>? = nil
}

struct DropHandlerEnvironmentKey: EnvironmentKey {
	static let defaultValue: DropHandler = { _, _, _ in return false }
}

extension EnvironmentValues {
	var dropHandler: DropHandler {
		get { self[DropHandlerEnvironmentKey.self] }
		set { self[DropHandlerEnvironmentKey.self] = newValue }
	}

	public var minuteHeight: CGFloat {
		get { self[MinuteHeightEnvironmentKey.self] }
		set { self[MinuteHeightEnvironmentKey.self] = newValue }
	}

	public var scheduleDaySpacing: CGFloat {
		get { self[DaySpacingEnvironmentKey.self] }
		set { self[DaySpacingEnvironmentKey.self] = newValue }
	}

	public var newEventDuration: TimeInterval {
		get { self[NewEventDurationEnvironmentKey.self] }
		set { self[NewEventDurationEnvironmentKey.self] = newValue }
	}

	public var roundToNearestMinute: TimeInterval {
		get { self[RoundToNearestMinuteEnvironmentKey.self] }
		set { self[RoundToNearestMinuteEnvironmentKey.self] = newValue }
	}

	public var startHour: Int {
		get { self[StartHourEnvironmentKey.self] }
		set { self[StartHourEnvironmentKey.self] = newValue }
	}

	public var endHour: Int {
		get { self[EndHourEnvironmentKey.self] }
		set { self[EndHourEnvironmentKey.self] = newValue }
	}

	public var hourLabelHeight: CGFloat {
		get { self[HourLabelHeightEnvironmentKey.self] }
		set { self[HourLabelHeightEnvironmentKey.self] = newValue }
	}

}

protocol ScheduleView: View {
	var minuteHeight: CGFloat { get }
	var startHour: Int { get }
	var endHour: Int { get }
	var hourLabelHeight: CGFloat { get }
	var frame: CGRect? { get set }
	var roundToNearestMinute: TimeInterval { get }
}

extension ScheduleView {
	var totalDayHeight: CGFloat { CGFloat(endHour - startHour) * hourHeight }
	var hourHeight: CGFloat { minuteHeight * 60 }
	
	func minuteOffset(for y: CGFloat, in frame: CGRect) -> TimeInterval? {
		let actualY = y + paddingDueToHourLabel.top
		if actualY < frame.minY || actualY > frame.maxY { return nil }
		
		let raw = TimeInterval((actualY - frame.minY) / minuteHeight) + TimeInterval(startHour * 60)
		return raw - TimeInterval(minuteHeight * -15)
	}
	
	func height(forMinutes minutes: Int) -> CGFloat {
		CGFloat(minutes) * minuteHeight
	}
	
	func offset(ofMinutes minutes: Int) -> CGFloat {
		CGFloat(minutes - startHour * 60) * minuteHeight + paddingDueToHourLabel.top
	}
	
	var paddingDueToHourLabel: EdgeInsets {
		EdgeInsets(top: hourLabelHeight / 2, leading: 0, bottom: hourLabelHeight / 2, trailing: 0)
	}
	
	func minutesFromMidnight(for y: CGFloat) -> Int? {
		guard let frame, let minute = minuteOffset(for: y, in: frame) else { return nil }
		
		return Int(round(minute / roundToNearestMinute) * roundToNearestMinute)
	}
}

extension View {
	func hourString(forMinute minute: Int) -> String {
		let hour = minute / 60
		let remainder = minute % 60
		
		return String(format: "%d:%02d", hour, remainder)
	}
}
