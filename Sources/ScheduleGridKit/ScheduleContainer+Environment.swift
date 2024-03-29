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

struct ScheduleSearchTextFilterEnvironmentKey: EnvironmentKey {
	static var defaultValue = ""
}

struct HourCycleEnvironmentKey: EnvironmentKey {
	static var defaultValue = HourMode.oneToTwelve
}

struct StartHourEnvironmentKey: EnvironmentKey {
	static var defaultValue = 6
}

struct EndHourEnvironmentKey: EnvironmentKey {
	static var defaultValue = 24
}

struct DaySpacingEnvironmentKey: EnvironmentKey {
	static var defaultValue = 5.0
}

struct HourLabelHeightEnvironmentKey: EnvironmentKey {
	static var defaultValue = 14.0
}

struct RoundToNearestMinuteEnvironmentKey: EnvironmentKey {
	static var defaultValue = 5.0
}

struct NewEventDurationEnvironmentKey: EnvironmentKey {
	static var defaultValue = 30.0 * 60.0
}

struct DropHandlerPreferenceKey: PreferenceKey {
	static func reduce(value: inout IDBox<DropHandler, String>?, nextValue: () -> IDBox<DropHandler, String>?) {
		value = value ?? nextValue()
	}
	
	static var defaultValue: IDBox<DropHandler, String>? = nil
}

struct DropHandlerEnvironmentKey: EnvironmentKey {
	static let defaultValue: IDBox<DropHandler, String>? = nil
}

struct CreateNewItemHandlerEnvironmentKey: EnvironmentKey {
	static let defaultValue: IDBox<CreateNewItemHandler, String>? = nil
}

extension EnvironmentValues {
	public var scheduleSearchTextFilter: String {
		get { self[ScheduleSearchTextFilterEnvironmentKey.self] }
		set { self[ScheduleSearchTextFilterEnvironmentKey.self] = newValue }
	}
	var hourCycle: HourMode {
		get { self[HourCycleEnvironmentKey.self] }
		set { self[HourCycleEnvironmentKey.self] = newValue }
	}
	
	var dropHandler: IDBox<DropHandler, String>? {
		get { self[DropHandlerEnvironmentKey.self] }
		set { self[DropHandlerEnvironmentKey.self] = newValue }
	}

	public var createNewItemHandler: IDBox<CreateNewItemHandler, String>? {
		get { self[CreateNewItemHandlerEnvironmentKey.self] }
		set { self[CreateNewItemHandlerEnvironmentKey.self] = newValue }
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
		let actualY = y - paddingDueToHourLabel.top
		if actualY < frame.minY || actualY > frame.maxY { return nil }
		
		let raw = TimeInterval((actualY - frame.minY) / minuteHeight) + TimeInterval(startHour * 60)
		return raw
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
		guard let frame, let minute = minuteOffset(for: y, in: CGRect(origin: .zero, size: frame.size)) else { return nil }
		
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
