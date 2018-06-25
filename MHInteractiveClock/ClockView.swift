//
//  ClockView.swift
//  ClockTest
//
//  Created by Maiko Hermans on 20/06/2018.
//  Copyright © 2018 dtt. All rights reserved.
//

import UIKit

protocol ClockViewDelegate: class {
    func didSelectHours(hours: CGFloat)
    func didSelectMinutes(minutes: CGFloat)
}

public class ClockView: UIView {
    // MARK: - Public Variables
    /// Contains all the styleable elements of the clock
    public var style = Style()
    /// Contains all the functional elements of the clock
    public lazy var functionality = { return Functionality(self) }()
    
    // MARK: - Private Variables
    private var clockFaceLayer: CALayer!
    private var centerLayer: CALayer!
    private var handleLayer: CALayer!
    private var radius: CGFloat!
    private var numberLayers: [CATextLayer] = []
    private var gestureEndTimer = Timer()
    
    private var currentSelectedTextLayer: CATextLayer?
    private var currentSelectedLayer: CALayer?
    private var currentSelectedTick: CAShapeLayer?
    
    private lazy var locationInView: UIView = {
        return self.window?.rootViewController?.view ?? self.superview ?? self
    }()
    
    /// Draw the initial clock
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        drawClockFace()
        drawClockCenter()
        drawHourHandle()
        drawNumbers(isHours: functionality.isHours)
        setCurrentHour()
        
        self.frame.origin.y = frame.midY - (frame.width / 2)
        self.backgroundColor = .clear
        
        clockFaceLayer.addSublayer(handleLayer)
        clockFaceLayer.addSublayer(centerLayer)
        
        layer.addSublayer(clockFaceLayer)
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragClockHandle(_:))))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressClockHandle(_:))))
    }
    
    /// Draw the ticks for the clock
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
         drawTicks()
    }
    
}

// MARK: - Handling User Input
extension ClockView {
    
    /// Switch from hours to minutes and the other way around when the gesture ended state has been triggered.
    @objc private func endGesture() {
        guard functionality.autoSwitch else { return }
        
        functionality.isHours = !functionality.isHours
        currentSelectedLayer?.removeFromSuperlayer()
        currentSelectedTick?.removeFromSuperlayer()
    }
    
    /// Draw the selected state of the tick that corresponds with the direction the clock handle is pointing at.
    ///
    /// - Parameter degree: The degree in the circle that match with the clock handle.
    private func drawSelectedTick(degree: Double) {
        guard functionality.displaySelectedTick == true else { return }
        
        let angle = ((degree - 90) * Double.pi) / 180
        let fitsIn = Int(degree) % 30 == 0
        let size = fitsIn ? radius * style.selectedHourTickMultiplier : radius * style.selectedMinuteTickMultiplier
        let color = fitsIn ? functionality.displaySelectedHourTick ? style.selectedHourTickColor : .clear : style.selectedMinuteTickColor
        let width = fitsIn ? style.selectedHourTickWidth : style.selectedMinuteTickWidth
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: radius + CGFloat(cos(angle)) * radius, y: radius + CGFloat(sin(angle)) * radius))
        path.addLine(to: CGPoint(x: radius + CGFloat(cos(angle)) * size, y: radius + CGFloat(sin(angle)) * size))
        
        currentSelectedTick?.removeFromSuperlayer()
        currentSelectedTick = CAShapeLayer()
        currentSelectedTick?.path = path.cgPath
        currentSelectedTick?.strokeColor = color.cgColor
        currentSelectedTick?.lineWidth = width
        
        clockFaceLayer.addSublayer(currentSelectedTick!)
    }
    
    /// Handle dragging the clock handle when the user starts panning inside the clock.
    ///
    /// - Parameter sender: The UIPanGesture.
    @objc func dragClockHandle(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            gestureEndTimer.invalidate()
        }
        
        let centerPoint = CGPoint(x: frame.midX, y: frame.midY)
        let touchPoint = sender.location(in: locationInView)
        let angle = atan2(touchPoint.x - centerPoint.x, touchPoint.y - centerPoint.y)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        handleLayer.transform = CATransform3DMakeRotation(-angle, 0, 0, 1)
        CATransaction.commit()
        
        obtainTime(angle: angle, isHours: functionality.isHours, snap: false)
        
        if sender.state == .ended {
            obtainTime(angle: angle, isHours: functionality.isHours)
            gestureEndTimer = Timer.scheduledTimer(timeInterval: functionality.switchDelay,
                                                   target: self, selector: #selector(endGesture), userInfo: nil, repeats: false)
        }
    }
    
    /// Handle displaying of the clock when the user pressed on a location inside the clock.
    ///
    /// - Parameter sender: The UITapGesture.
    @objc func pressClockHandle(_ sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
            gestureEndTimer.invalidate()
        }
        
        let centerPoint = CGPoint(x: frame.midX, y: frame.midY)
        let touchPoint = sender.location(in: locationInView)
        let angle = atan2(touchPoint.x - centerPoint.x, touchPoint.y - centerPoint.y)
        
        handleLayer.transform = CATransform3DMakeRotation(-angle, 0, 0, 1)
        
        if sender.state == .ended {
            obtainTime(angle: angle, isHours: functionality.isHours)
            gestureEndTimer = Timer.scheduledTimer(timeInterval: functionality.switchDelay,
                                                   target: self, selector: #selector(endGesture), userInfo: nil, repeats: false)
        }
    }
    
}

// MARK: - Helper Functions
extension ClockView {
    
    /// Remove all the numbers from the clock face.
    private func cleanNumbers() {
        numberLayers.forEach { $0.removeFromSuperlayer() }
        numberLayers.removeAll()
    }
    
    /// Obtain the TextLayer that is on the clockface that matches with the degrees the handle is pointed at.
    ///
    /// - Parameter degree: The degree in the circle the hour handle is pointed at by the user.
    /// - Returns: The CATextLayer that matches with the users input if any.
    private func obtainTextLayer(degree: Double) -> CATextLayer? {
        let degree = degree == 0 ? 360 : degree
        var matchingNumberLayer: CATextLayer?
        numberLayers.forEach {
            if Double($0.name ?? "0") == degree {
                matchingNumberLayer = $0
                return
            }
        }
        return matchingNumberLayer
    }
    
    /// Obtain the selected time based on the input degree of the clock handle.
    ///
    /// - Parameters:
    ///   - angle: Angle in radiants of the clock handle.
    ///   - isHours: Whether hours or minutes are being displayed
    ///   - snap: If it needs to snap to an exact value either minute or hour.
    func obtainTime(angle: CGFloat, isHours: Bool = true, snap: Bool = true) {
        let degrees = (angle * 180 / .pi) - 180
        
        if isHours {
            var hour = (-degrees / 30).rounded()
            hour = hour == 0 ? 12 : hour
            functionality.delegate?.didSelectHours(hours: hour)
            
            guard snap else { return }
            snapHandleToValue(degrees: hour * 30)
        } else {
            let minute = (-degrees / 6).rounded()
            functionality.delegate?.didSelectMinutes(minutes: minute)
            
            guard snap else { return }
            snapHandleToValue(degrees: minute * 6)
        }
    }
    
    /// Handle the clock handle snapping to the right location and displaying everything in the way the user desires.
    ///
    /// - Parameter degrees: The degree of the clock handle.
    private func snapHandleToValue(degrees: CGFloat) {
        handleLayer.transform = CATransform3DMakeRotation(((degrees + 180) * .pi) / 180, 0, 0, 1)
        
        let string = currentSelectedTextLayer?.string as? NSAttributedString
        let number = NSAttributedString(string: string?.string ?? "", attributes:[
            NSAttributedStringKey.foregroundColor: style.numberColor, NSAttributedStringKey.font: style.numberFont])
        currentSelectedTextLayer?.string = number
        currentSelectedTextLayer?.bounds.size = number.size()
        currentSelectedLayer?.removeFromSuperlayer()
        
        drawSelectedTick(degree: Double(degrees))
        
        if let textLayer = obtainTextLayer(degree: Double(degrees)) {
            let layer = CALayer()
            layer.frame = textLayer.frame
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer.position = CGPoint(x: layer.frame.midX, y: layer.frame.midY)
            layer.bounds.size.width = self.frame.width * style.selectedCircleSize
            layer.bounds.size.height = self.frame.width * style.selectedCircleSize
            layer.cornerRadius = layer.frame.width / 2
            layer.backgroundColor = style.selectedCircleColor.cgColor
            clockFaceLayer.insertSublayer(layer, at: 0)
            
            let string = textLayer.string as? NSAttributedString
            let number = NSAttributedString(string: string?.string ?? "",
                                            attributes: [NSAttributedStringKey.foregroundColor: style.selectedCircleTextColor, NSAttributedStringKey.font: style.selectedCircleFont])
            textLayer.string = number
            textLayer.bounds.size = number.size()
            
            currentSelectedLayer = layer
            currentSelectedTextLayer = textLayer
        }
    }
    
}

// MARK: - Draw Clock Methods
extension ClockView {
    
    /// Draw the face of the clock. In this layer all other clock related layers will be placed.
    private func drawClockFace() {
        clockFaceLayer = CALayer()
        clockFaceLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        clockFaceLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        clockFaceLayer.frame.size.height = frame.width
        clockFaceLayer.cornerRadius = frame.width / 2
        clockFaceLayer.borderWidth = style.clockFaceBorderWidth
        clockFaceLayer.borderColor = style.clockFaceBorderColor.cgColor
        clockFaceLayer.backgroundColor = UIColor.clear.cgColor
        radius = clockFaceLayer.frame.width / 2
    }
    
    /// Draw the center of the clock.
    private func drawClockCenter() {
        centerLayer = CALayer()
        centerLayer.frame = clockFaceLayer.frame
        centerLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        centerLayer.position = CGPoint(x: clockFaceLayer.bounds.midX, y: clockFaceLayer.bounds.midY)
        centerLayer.bounds = CGRect(x: 0, y: 0, width: style.clockCenterSize, height: style.clockCenterSize)
        centerLayer.backgroundColor = style.clockCenterColor.cgColor
        centerLayer.cornerRadius = centerLayer.bounds.width / 2
    }
    
    /// Draw the hour handle of the clock.
    private func drawHourHandle() {
        handleLayer = CALayer()
        handleLayer.frame = clockFaceLayer.frame
        handleLayer.backgroundColor = style.clockHandColor.cgColor
        handleLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
        handleLayer.position = CGPoint(x: clockFaceLayer.bounds.midX, y: clockFaceLayer.bounds.midY)
        handleLayer.bounds = CGRect(x: 0, y: 0, width: style.clockHandWidth, height: (clockFaceLayer.bounds.width / 2) * style.clockHandHeightMultiplier)
        handleLayer.allowsEdgeAntialiasing = true
    }
    
    /// Set the hour handle to the current hour.
    private func setCurrentHour() {
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: Date())
        let hourAngle = -Double(hours % 12) * 360.0 / 12 + 180
        
        handleLayer.transform = CATransform3DMakeRotation(CGFloat(hourAngle * Double.pi / -180), 0, 0, 1)
    }
    
    /// Draw out the values on the clock, the values could either be minutes or in hours.
    ///
    /// - Parameter isHours: Whether the hour or minute values need to be used.
    func drawNumbers(isHours: Bool) {
        guard functionality.displayNumbers else { return }
        
        cleanNumbers()
        
        let txtRadius: Double = Double(radius) * style.numberRadius
        for i in 1...12{
            var numberValue = isHours == true ? String(i) : String(i * 5)
            numberValue = numberValue == "60" ? "00" : numberValue
            let number = NSAttributedString(string: numberValue,
                                            attributes: [NSAttributedStringKey.foregroundColor: style.numberColor,
                                                         NSAttributedStringKey.font: style.numberFont])
            let angle = (-(Double(i) * 30.0) + 90) * Double.pi / -180
            let numberRect =  CGRect( x:CGFloat(Double(radius) + cos(angle) * txtRadius - Double(number.size().width/2)),
                                      y:CGFloat(Double(radius) + sin(angle) * txtRadius - Double(number.size().height/2)),
                                      width:number.size().width,
                                      height:number.size().height)
            let textLayer = CATextLayer()
            textLayer.frame = numberRect
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.string = number
            textLayer.name = String(Double(i) * 30)
            numberLayers.append(textLayer)
            clockFaceLayer.addSublayer(textLayer)
        }
    }
    
    /// Draw the ticks of the clock.
    private func drawTicks(){
        guard functionality.displayTicks else { return }
        
        for i in 1...60{
            let angle = Double(i) * 6.0 * Double.pi / 180
            let path = UIBezierPath()
            path.move(to: CGPoint(x: radius + CGFloat(cos(angle)) * radius, y: radius + CGFloat(sin(angle)) * radius))
            
            let size = i % 5 == 0 ? radius * style.hourTickMultiplier : radius * style.minuteTickMultiplier
            let color = i % 5 == 0 ? style.hourTickColor : style.minuteTickColor
            
            color.setStroke()
            path.addLine(to: CGPoint(x: radius + CGFloat(cos(angle)) * size, y: radius + CGFloat(sin(angle)) * size))
            path.stroke()
        }
    }
    
}
