//
//  ClockDetails.swift
//  ClockTest
//
//  Created by Maiko Hermans on 22/06/2018.
//  Copyright © 2018 dtt. All rights reserved.
//

import UIKit

/// 🎨 Styling of the Clock View.
public struct Style {
    /// Width of the Clock Face.
    public var clockFaceBorderWidth: CGFloat = 4
    /// Color of the Clock Face.
    public var clockFaceBorderColor: UIColor = .orange
    
    /// Size of the Clock Center.
    public var clockCenterSize: CGFloat = 10
    /// Color of the Clock Center.
    public var clockCenterColor: UIColor = .blue
    
    /// Width of the Clock Hand.
    public var clockHandWidth: CGFloat = 3
    /// Color of the Clock Hand.
    public var clockHandColor: UIColor = .blue
    /// Height Multiplier of the Clock Hand, based on the size of the View. This is a Multiplier between 0 - 1.
    public var clockHandHeightMultiplier: CGFloat = 0.75
    
    /// Font of the Numbers being displayed in the Clock.
    public var numberFont: UIFont = UIFont.systemFont(ofSize: 14)
    /// Color of the Numbers being displayed in the Clock.
    public var numberColor: UIColor = .black
    /// Place of the numbers inside of the Clock View. This is a Multiplier between 0 - 1.
    public var numberRadius: Double = 0.85
    
    /// Color of the Circle around the Number that has been selected.
    public var selectedCircleColor: UIColor = .blue
    /// Size of the Circle around the Number that has been selected.
    public var selectedCircleSize: CGFloat = 0.1
    /// Font of the Number that has been selected.
    public var selectedCircleFont: UIFont = UIFont.systemFont(ofSize: 14)
    /// TextColor of the Number that has been selected.
    public var selectedCircleTextColor: UIColor = .white
    
    /// Size of the Tick of the Hours. This is a Multiplier between 0 - 1.
    public var hourTickMultiplier: CGFloat = 0.9
    /// Size of the Tick of the Minutes. This is a Multiplier between 0 - 1.
    public var minuteTickMultiplier: CGFloat = 0.95
    /// Color of the Tick of the Hours.
    public var hourTickColor: UIColor = .black
    /// Color of the Tick of the Minutes.
    public var minuteTickColor: UIColor = .lightGray
    
    /// Size of the Tick of the Hour that has been selected. This is a Multiplier between 0 - 1.
    public var selectedHourTickMultiplier: CGFloat = 0.9
    /// Size of the Tick of the Minute that has been selected. This is a Multiplier between 0 - 1.
    public var selectedMinuteTickMultiplier: CGFloat = 0.95
    /// Color of the Tick of the Hour that has been selected.
    public var selectedHourTickColor: UIColor = .red
    /// Color of the Tick of the Minute that has been selected.
    public var selectedMinuteTickColor: UIColor = .blue
    /// Width of the Tick of the Hour that has been selected.
    public var selectedHourTickWidth: CGFloat = 1
    /// Width of the tick of the Minute that has been selected.
    public var selectedMinuteTickWidth: CGFloat = 1
}

/// ⚙️ Functional Attributes of the Clock.
public struct Functionality {
    /// Delegate of the Clock.
    public weak var delegate: ClockViewDelegate?
    /// Switch between Hours and Minutes automatically when the Clock Hand has been interacted with.
    public var autoSwitch: Bool = true
    /// Switch between Hours and Minutes with set delay.
    public var switchDelay: Double = 1.5
    /// Whether the hours needs to be displayed or the minutes.
    public var isHours: Bool = true { didSet { clock.drawNumbers(isHours: isHours) } }
    /// Whether the numbers need to be displayed or not.
    public var displayNumbers: Bool = true { didSet { clock.drawNumbers(isHours: isHours) } }
    /// Whether the ticks need to be displayed or not.
    public var displayTicks: Bool = true { didSet { clock.drawNumbers(isHours: isHours) } }
    /// Whether the selected tick needs to be displayed or not.
    public var displaySelectedTick: Bool = true
    /// Whether the tick needs to be displayed or not if the selected number is an hour mark.
    public var displaySelectedHourTick: Bool = false
    
    private weak var clock: ClockView!
    
    public init(_ clock: ClockView) {
        self.clock = clock
    }
}


