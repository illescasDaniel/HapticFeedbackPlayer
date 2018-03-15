//
//  ViewController.swift
//  HapticFeedbackPlayer
//
//  Created by Daniel Illescas Romero on 15/03/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func customHaptic1Action(_ sender: UIButton) {
		
		HapticFeedback()
			.selectionChanged.then(after: .milliseconds(200))
			.selectionChanged.then(after: .milliseconds(200))
			.selectionChanged.then(after: .milliseconds(200))
		.play()
	}
	
	@IBAction func customHaptic2Action(_ sender: UIButton) {
		HapticFeedback()
			.selectionChanged.then(after: .milliseconds(200))
		.replay(times: 3)
	}
	
	@IBAction func customHaptic3Action(_ sender: UIButton) {
		HapticFeedback()
			.selectionChanged.replay(times: 2, withInterval: .milliseconds(300)).then(after: .milliseconds(150))
			.impactOcurredWith(style: .light).then(after: .seconds(1))
			.notificationOcurredOf(type: .success)
		.play()
	}
}
