//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 4/12/23.
//

import Suite

public extension View {
	func createNewItemHandler(_ id: () -> String = { "\(#file):\(#line)" }, handler: @escaping CreateNewItemHandler) -> some View {
		self
			.environment(\.createNewItemHandler, IDBox(contents: handler, id: id()))
	}
}
