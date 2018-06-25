<html>
<H1 align="center">MHInteractiveClock</H1>
<p align="center">
  <img src="https://img.shields.io/github/stars/MaikoHermans/MHInteractiveClock.svg" alt="Github stars"/>
  <img src="https://img.shields.io/github/issues/MaikoHermans/MHInteractiveClock.svg" alt="GitHub issues"/>
  <img src="https://img.shields.io/github/license/MaikoHermans/MHInteractiveClock.svg" alt="GitHub license"/>
  </p>
</html>

`MHInteractiveClock` is a pod that will allow you to draw a clock which can be interacted with in your app. 

You will no longer have to figure out all the required formulas to draw the clock handles and use the input of a user.  
MHInteractiveClock is easy stylable to your likings.

Installation
==========================

#### Installation with CocoaPods

***MHInteractiveClock:*** MHInteractiveClock is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

```ruby
pod 'MHInteractiveKeyboard'
```

Usage
==========================

Firstly `import MHInteractiveClock` in the class you would like to draw out the clock.

```swift 
import MHInteractiveClock 
```

### Initialization

You can now use the Clock by either using storyboard or code.

#### StoryBoard:
![alt text](https://github.com/MaikoHermans/MHInteractiveClock/blob/master/Images/storyboard.gif "Storyboard Initialization")

#### Code:
All you have to do is specify the frame (or use constraints if you prefer) like below

```swift
let clock = ClockView(frame: CGRect(x: 0, y: 0, width: 375, height: 375))
        
view.addSubview(clock)
```

### Style
You are able to change multiple things regarding the styling of the clock. 

- clockFaceBorderWidth
- clockFaceBorderColor
- clockCenterSize
- clockCenterColor
- clockHandWidth
- clockHandColor
- clockHandHeightMultiplier
- numberFont
- numberColor
- numberRadius
- selectedCircleColor
- selectedCircleSize
- selectedCircleFont
- selectedCircleTextColor
- hourTickMultiplier
- minuteTickMultiplier
- hourTickColor
- minuteTickColor
- selectedHourTickMultiplier
- selectedMinuteTickMultiplier
- selectedHourTickColor
- selectedMinuteTickColor
- selectedHourTickWidth
- selectedMinuteTickWidth

### Control
You are also able to manipulte certain characteristics of the clock.

- delegate
- autoSwitch
- switchDelay
- isHours
- displayNumbers
- displayTicks
- displaySelectedTick
- displaySelectedHourTick

### Delegate Functions
The clock has a few delegate functions which tell you which time is currently selected by the user.

#### Selected Hours
This function will be called when the user interacted with the handle when the hour state was active. It will pass you the hour that's currently selected by the user.

```swift
func didSelectHours(hours: CGFloat)
```

#### Selected Minutes
This function will be called when the user interacted with the handle when the minute state was active. It will pass you the minute that's currently selected by the user.

```swift
func didSelectMinutes(minutes: CGFloat)
```
