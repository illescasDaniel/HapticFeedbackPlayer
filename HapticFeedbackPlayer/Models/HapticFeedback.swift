/*
The MIT License (MIT)

Copyright (c) 2018 Daniel Illescas Romero <https://github.com/illescasDaniel>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit

extension DispatchTime {
	static func +=(lhs: inout DispatchTime, interval: DispatchTimeInterval) {
		lhs = lhs + interval
	}
}

typealias FeedbackGenerator = HapticFeedback.FeedbackGenerator

class HapticFeedback {
	
	fileprivate enum HapticEffect {
		case none
		case selectionChanged
		case lightImpact
		case mediumImpact
		case heavyImpact
		case notificationSuccess
		case notificationError
		case notificationWarning
	}
	
	class FeedbackGenerator {
		
		static let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
		static let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
		static let heavyImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
		static let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
		static let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
		
		fileprivate init() {}
		
		static func impactOcurredWith(style: UIImpactFeedbackStyle) {
			switch(style) {
			case .light: FeedbackGenerator.lightImpactFeedbackGenerator.impactOccurred()
			case .medium: FeedbackGenerator.mediumImpactFeedbackGenerator.impactOccurred()
			case .heavy: FeedbackGenerator.heavyImpactFeedbackGenerator.impactOccurred()
			}
		}
		
		static func notificationOcurredOf(type: UINotificationFeedbackType) {
			FeedbackGenerator.notificationFeedbackGenerator.notificationOccurred(type)
		}
		
		static func selectionChanged() {
			FeedbackGenerator.selectionFeedbackGenerator.selectionChanged()
		}
	}
	
	private var accumulatedTime: DispatchTime = .now()
	private var lastHaptic: HapticEffect = .none
	private var lastInterval: DispatchTimeInterval = .milliseconds(0)
	
	init() {}
	
	init(after: DispatchTimeInterval) {
		self.accumulatedTime += after
	}
	
	var selectionChanged: HapticFeedback {
		
		self.lastHaptic = .selectionChanged
		
		FeedbackGenerator.selectionFeedbackGenerator.prepare()
		
		DispatchQueue.main.asyncAfter(deadline: self.accumulatedTime) {
			FeedbackGenerator.selectionChanged()
		}
		return self
	}
	
	func impactOcurredWith(style: UIImpactFeedbackStyle) -> HapticFeedback {
		
		switch style {
		case .light: FeedbackGenerator.lightImpactFeedbackGenerator.prepare(); self.lastHaptic = .lightImpact
		case .medium: FeedbackGenerator.mediumImpactFeedbackGenerator.prepare(); self.lastHaptic = .mediumImpact
		case .heavy: FeedbackGenerator.heavyImpactFeedbackGenerator.prepare(); self.lastHaptic = .heavyImpact
		}
		
		DispatchQueue.main.asyncAfter(deadline: self.accumulatedTime) {
			FeedbackGenerator.impactOcurredWith(style: style)
		}
		return self
	}
	
	func notificationOcurredOf(type: UINotificationFeedbackType) -> HapticFeedback {
		
		switch type {
		case .success: self.lastHaptic = .notificationSuccess
		case .error: self.lastHaptic = .notificationError
		case .warning: self.lastHaptic = .notificationWarning
		}
		
		FeedbackGenerator.notificationFeedbackGenerator.prepare()
		
		DispatchQueue.main.asyncAfter(deadline: self.accumulatedTime) {
			FeedbackGenerator.notificationOcurredOf(type: type)
		}
		return self
	}
	
	func then(after: DispatchTimeInterval) -> HapticFeedback {
		self.accumulatedTime += after
		self.lastInterval = after
		return self
	}
	
	var then: HapticFeedback {
		return self
	}
	
	func replay(times: UInt) {
		
		guard times > 0 else { return }
		
		for _ in 0..<times-1 {
			
			switch self.lastHaptic {
			case .none: break
			case .selectionChanged: let _ = self.selectionChanged
			case .lightImpact: let _ = self.impactOcurredWith(style: .light)
			case .mediumImpact: let _ = self.impactOcurredWith(style: .medium)
			case .heavyImpact: let _ = self.impactOcurredWith(style: .heavy)
			case .notificationSuccess: let _ = self.notificationOcurredOf(type: .success)
			case .notificationError: let _ = self.notificationOcurredOf(type: .error)
			case .notificationWarning: let _ = self.notificationOcurredOf(type: .warning)
			}
			
			self.accumulatedTime += self.lastInterval
		}
		
		self.play()
	}
	
	func replay(times: UInt, withInterval interval: DispatchTimeInterval) -> HapticFeedback {
		
		guard times > 0 else { return self }
		
		for _ in 0..<times-1 {
			
			self.accumulatedTime += interval
			
			switch self.lastHaptic {
			case .none: break
			case .selectionChanged: let _ = self.selectionChanged
			case .lightImpact: let _ = self.impactOcurredWith(style: .light)
			case .mediumImpact: let _ = self.impactOcurredWith(style: .medium)
			case .heavyImpact: let _ = self.impactOcurredWith(style: .heavy)
			case .notificationSuccess: let _ = self.notificationOcurredOf(type: .success)
			case .notificationError: let _ = self.notificationOcurredOf(type: .error)
			case .notificationWarning: let _ = self.notificationOcurredOf(type: .warning)
			}
		}
		
		return self
	}
	
	func play() {
		self.accumulatedTime = .now()
	}
}
