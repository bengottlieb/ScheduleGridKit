//
//  HourMode.swift
//  
//
//  Created by Ben Gottlieb on 7/8/23.
//

import Foundation

public enum HourMode: String, Codable, Hashable, Sendable {
		case zeroToEleven
		case oneToTwelve
		case zeroToTwentyThree
		case oneToTwentyFour
	
	static var current: HourMode {
		if #available(iOS 16, *) {
			return Self.from(Locale.current.hourCycle)
		} else {
			return .oneToTwelve
		}
	}
}

extension HourMode {
	@available(iOS 16, *)
	static func from(_ cycle: Locale.HourCycle) -> HourMode {
		switch cycle {
			
		case .zeroToEleven: return .zeroToEleven
		case .oneToTwelve: return .oneToTwelve
		case .zeroToTwentyThree: return .zeroToTwentyThree
		case .oneToTwentyFour: return .oneToTwentyFour
		@unknown default: return .oneToTwelve
		}
	}
}
