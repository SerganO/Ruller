//
//  ViewController.swift
//  Ruller
//
//  Created by Serhii Ostrovetskyi on 9/4/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    let rullerView = UIView()
    
    var topLeftPoint = CGPoint()
    var bottomLeftPoint = CGPoint()
    var topRightPoint = CGPoint()
    var bottomRightPoint = CGPoint()
    
    var rec = CAShapeLayer()
    var circle = CAShapeLayer()
    
    let rullerPOintRec = CAShapeLayer()
    
    let width = UIScreen.main.bounds.size.width
    let height: CGFloat = 100.0
    
    let minX: CGFloat = 0
    let minY: CGFloat = 0
    let maxX: CGFloat = UIScreen.main.bounds.size.width
    let maxY: CGFloat = UIScreen.main.bounds.size.height
    
    var panInRec = false
    var rotateInRec = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0...70 {
            let horizontalRec = UIBezierPath()
            let hRec = CAShapeLayer()
            let hTL = CGPoint(x: 0, y: 10 * i)
            let hBL = CGPoint(x: 0, y:  10 * i + 1)
            let hTR = CGPoint(x: Int(UIScreen.main.bounds.size.width), y: 10 * i)
            let hBR = CGPoint(x: Int(UIScreen.main.bounds.size.width), y: 10 * i + 1)
            horizontalRec.move(to: hTL)
            horizontalRec.addLine(to: hTR)
            horizontalRec.addLine(to: hBR)
            horizontalRec.addLine(to: hBL)
            horizontalRec.close()
            hRec.path = horizontalRec.cgPath
            hRec.fillColor = UIColor.black.cgColor
            view.layer.addSublayer(hRec)
        }
        
        for i in 0...35 {
            let rectangle = UIBezierPath()
            let rec = CAShapeLayer()
            topLeftPoint = CGPoint(x: 10 * i, y: 0)
            bottomLeftPoint = CGPoint(x: 10 * i, y:  Int(UIScreen.main.bounds.size.height))
            topRightPoint = CGPoint(x: 10 * i + 1, y: 0)
            bottomRightPoint = CGPoint(x: 10 * i + 1, y: Int(UIScreen.main.bounds.size.height))
            rectangle.move(to: topLeftPoint)
            rectangle.addLine(to: topRightPoint)
            rectangle.addLine(to: bottomRightPoint)
            rectangle.addLine(to: bottomLeftPoint)
            rectangle.close()
            rec.path = rectangle.cgPath
            rec.fillColor = UIColor.black.cgColor
            view.layer.addSublayer(rec)
        }
        
        
        rullerView.backgroundColor = .green
        rullerView.frame = CGRect(x: 20, y: 20, width: 200, height: 100)
        
        //view.addSubview(rullerView)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(move(gestureRecognizer:)))
        rullerView.addGestureRecognizer(gesture)
        rullerView.isUserInteractionEnabled = true
        gesture.delegate = self
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate(gestureRecognizer:)))
        rullerView.addGestureRecognizer(rotateGesture)
        rotateGesture.delegate = self
        
        let rectangle = UIBezierPath()
        topLeftPoint = CGPoint(x: 0, y: 0)
        bottomLeftPoint = CGPoint(x: 0, y:  height)
        topRightPoint = CGPoint(x: width, y: 0)
        bottomRightPoint = CGPoint(x: width, y: height)
        rectangle.move(to: topLeftPoint)
        rectangle.addLine(to: topRightPoint)
        rectangle.addLine(to: bottomRightPoint)
        rectangle.addLine(to: bottomLeftPoint)
        rectangle.close()
        rec.path = rectangle.cgPath
        rec.fillColor = UIColor.lightGray.cgColor
        rec.borderColor = UIColor.black.cgColor
        rec.borderWidth = 10
        rec.opacity = 0.4
        view.layer.addSublayer(rec)
        
        
        view.addGestureRecognizer(gesture)
        view.addGestureRecognizer(rotateGesture)
        
        let centerPoint = CGPoint(x: topLeftPoint.x + rullerLenght / 2, y: topLeftPoint.y + height / 2)
        order(centerPoint)
    }
    
    @objc func move(gestureRecognizer: UIPanGestureRecognizer) {
        //print("MOVE")
        var locationOfBeganTap: CGPoint
        
        var locationOfEndTap: CGPoint
        
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            locationOfBeganTap = gestureRecognizer.location(in: view)
            panInRec = false
            if pointInRec(locationOfBeganTap){
                print("IN REC")
                panInRec = true
            }
            
            
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            
            locationOfEndTap = gestureRecognizer.location(in: view)
        }
        
        guard panInRec else {
            return
        }
//        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
//        topLeftPoint.y += translation.y
//        bottomLeftPoint.y += translation.y
//        topRightPoint.y += translation.y
//        bottomRightPoint.y += translation.y
//        topLeftPoint.x += translation.x
//        bottomLeftPoint.x += translation.x
//        topRightPoint.x += translation.x
//        bottomRightPoint.x += translation.x
        
        let centerPoint = gestureRecognizer.location(in: view)
        print(centerPoint)
        
        let fLenght = sqrt((centerPoint.x) * (centerPoint.x) + (centerPoint.y) * (centerPoint.y))
        
        let sLenght = sqrt((centerPoint.x - maxX) * (centerPoint.x - maxX) + (centerPoint.y - maxY) * (centerPoint.y - maxY))
        
        let ffLenght = sqrt((centerPoint.x - maxX) * (centerPoint.x - maxX) + (centerPoint.y) * (centerPoint.y))
        
        let ssLenght = sqrt((centerPoint.x) * (centerPoint.x) + (centerPoint.y - maxY) * (centerPoint.y - maxY))
        
        let length = max(fLenght, sLenght, ffLenght, ssLenght) * 2
        
        
        var additionalXBias = abs(height / 2 * cos((.pi / 2) - angle))
        if angle >= 0 {
            additionalXBias = -additionalXBias
        }
        let additionalYBias = height / 2 * sin((.pi / 2) - angle)
        
        topLeftPoint.x = centerPoint.x - length / 2 * cos(angle) + additionalXBias
        topLeftPoint.y = centerPoint.y + length / 2 * sin(angle) - additionalYBias
        topRightPoint.x = topLeftPoint.x + length * cos(angle)
        topRightPoint.y = topLeftPoint.y - length * sin(angle)
        bottomLeftPoint.x = topLeftPoint.x + height * cos((.pi / 2) - angle)
        bottomLeftPoint.y = topLeftPoint.y + height * sin((.pi / 2) - angle)
        bottomRightPoint.x = bottomLeftPoint.x + length * cos(angle)
        bottomRightPoint.y = bottomLeftPoint.y - length * sin(angle)

        
        
        
        
        
        rec.removeFromSuperlayer()
        let rectangle = UIBezierPath()
        rectangle.move(to: topLeftPoint)
        rectangle.addLine(to: topRightPoint)
        rectangle.addLine(to: bottomRightPoint)
        rectangle.addLine(to: bottomLeftPoint)
        rectangle.close()
        rec.path = rectangle.cgPath
        rec.fillColor = UIColor.lightGray.cgColor
        rec.opacity = 0.4
        
        rec.borderWidth = 10
        rec.borderColor = UIColor.black.cgColor
        view.layer.addSublayer(rec)

        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: gestureRecognizer.view!)
        order(centerPoint)
    }
    
    //var preAngle: CGFloat = 0.0
    var angle: CGFloat = 0.0
    
    @objc func rotate(gestureRecognizer: UIRotationGestureRecognizer) {
        let firstPoint = gestureRecognizer.location(ofTouch: 0, in: view)
        let secondPoint = gestureRecognizer.location(ofTouch: 1, in: view)
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            rotateInRec = false
            if pointInRec(firstPoint), pointInRec(secondPoint) {
                print("rotate in rec")
                rotateInRec = true
            }
        }
        
        guard rotateInRec else {
            return
        }
        
        print("-----------------------------")
        
        angle = -atan2(secondPoint.y - firstPoint.y, secondPoint.x - firstPoint.x)
        print("ANGLE: \(angle * 180 / .pi)")

        let centerPoint = CGPoint(x: (secondPoint.x + firstPoint.x) / 2, y: (firstPoint.y + secondPoint.y) / 2)
        
        var additionalXBias = abs(height / 2 * cos((.pi / 2) - angle))
        if angle >= 0 {
            additionalXBias = -additionalXBias
        }
        let additionalYBias = height / 2 * sin((.pi / 2) - angle)
        
        print("X BIAS: \(-(width / 2 * cos(angle)) + additionalXBias)")
        print("Y BIAS: \(width / 2 * sin(angle) - additionalYBias)")
        
        let fLenght = sqrt((centerPoint.x) * (centerPoint.x) + (centerPoint.y) * (centerPoint.y))
        
        let sLenght = sqrt((centerPoint.x - maxX) * (centerPoint.x - maxX) + (centerPoint.y - maxY) * (centerPoint.y - maxY))
        
        let ffLenght = sqrt((centerPoint.x - maxX) * (centerPoint.x - maxX) + (centerPoint.y) * (centerPoint.y))
        
        let ssLenght = sqrt((centerPoint.x) * (centerPoint.x) + (centerPoint.y - maxY) * (centerPoint.y - maxY))
        
        let length = max(fLenght, sLenght, ffLenght, ssLenght) * 2
        
        
        topLeftPoint.x = centerPoint.x - length / 2 * cos(angle) + additionalXBias
        topLeftPoint.y = centerPoint.y + length / 2 * sin(angle) - additionalYBias
        topRightPoint.x = topLeftPoint.x + length * cos(angle)
        topRightPoint.y = topLeftPoint.y - length * sin(angle)
        bottomLeftPoint.x = topLeftPoint.x + height * cos((.pi / 2) - angle)
        bottomLeftPoint.y = topLeftPoint.y + height * sin((.pi / 2) - angle)
        bottomRightPoint.x = bottomLeftPoint.x + length * cos(angle)
        bottomRightPoint.y = bottomLeftPoint.y - length * sin(angle)
        
        
        rec.removeFromSuperlayer()
        let rectangle = UIBezierPath()
        rectangle.move(to: topLeftPoint)
        rectangle.addLine(to: topRightPoint)
        rectangle.addLine(to: bottomRightPoint)
        rectangle.addLine(to: bottomLeftPoint)
        rectangle.close()
        rec.path = rectangle.cgPath
        
        rec.fillColor = UIColor.lightGray.cgColor
        rec.borderWidth = 10
        rec.borderColor = UIColor.black.cgColor
        rec.opacity = 0.4
        view.layer.addSublayer(rec)
        gestureRecognizer.rotation = 0
        
        circle.removeFromSuperlayer()
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: CGFloat(20), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circle.path = circlePath.cgPath
        
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UIColor.green.cgColor
        circle.lineWidth = 3.0
        
        view.layer.addSublayer(circle)
        
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            circle.removeFromSuperlayer()
        }
        print("-----------------------------")
        order(centerPoint)
    }
    
    func pointInRec(_ point: CGPoint) -> Bool {
        let rectangle = UIBezierPath()
        rectangle.move(to: topLeftPoint)
        rectangle.addLine(to: topRightPoint)
        rectangle.addLine(to: bottomRightPoint)
        rectangle.addLine(to: bottomLeftPoint)
        rectangle.close()
        return rectangle.cgPath.boundingBox.contains(point)
        
//        print("TL: \(topLeftPoint)")
//        print("BL: \(bottomLeftPoint)")
//        print("TR: \(topRightPoint)")
//        print("BR: \(bottomRightPoint)")
//        print("P: \(point)")
//        return point.x >= topLeftPoint.x && point.y >= topLeftPoint.y &&
//        point.x <= topRightPoint.x && point.y >= topRightPoint.y &&
//        point.x <= bottomRightPoint.x && point.y <= bottomRightPoint.y &&
//        point.x >= bottomLeftPoint.x && point.y <= bottomLeftPoint.y
    }

    func rotate1() {
        let temp = topLeftPoint
        topLeftPoint = topRightPoint
        topRightPoint = bottomRightPoint
        bottomRightPoint = bottomLeftPoint
        bottomLeftPoint = temp
    }
    
    func rotate2() {
        
    }
    
    var rullerRect : CGRect {
        let rectangle = UIBezierPath()
        rectangle.move(to: topLeftPoint)
        rectangle.addLine(to: topRightPoint)
        rectangle.addLine(to: bottomRightPoint)
        rectangle.addLine(to: bottomLeftPoint)
        rectangle.close()
        return rectangle.cgPath.boundingBox
    }
    
    var rullerLenght: CGFloat {
        return sqrt((topLeftPoint.x - topRightPoint.x) * (topLeftPoint.x - topRightPoint.x) + (topLeftPoint.y - topRightPoint.y) * (topLeftPoint.y - topRightPoint.y))
    }
    var linaLayers = [CAShapeLayer()]
    
    func order(_ centerPoint: CGPoint) {
        for layer in linaLayers {
            layer.removeFromSuperlayer()
        }
        linaLayers.removeAll()
        var count = 40
        var cm: CGFloat = 65.0
        var mm: CGFloat = 6.5
        if let pointsPerCentimeter = UIScreen.pointsPerCentimeter {
            //count = Int(rullerLenght / pointsPerCentimeter)
            cm = pointsPerCentimeter
            mm = cm / 10
            count = Int(rullerLenght / mm)
        }
        
        let point1 = CGPoint(x: centerPoint.x - height/2 * cos((.pi / 2) - angle), y: centerPoint.y - height/2 * sin((.pi / 2) - angle))
        let point2 = CGPoint(x: centerPoint.x + height/2 * cos((.pi / 2) - angle), y: centerPoint.y + height/2 * sin((.pi / 2) - angle))
        print(centerPoint)
        
        for i in 0...(count / 2) {
            var size = height / 5
            if i % 10 == 0 {
                size = height / 3
            } else if i % 5 == 0 {
                size = height / 4
            }
            drawLine(for: point1, with: mm * CGFloat(i) - 1.5, 3, size)
            drawLine(for: point1, with: mm * -CGFloat(i) + 1.5, -3, size)
            drawLine(for: point2, with: mm * CGFloat(i) - 1.5, 3, -size)
            drawLine(for: point2, with: mm * -CGFloat(i) + 1.5, -3, -size)
        }
       
    }
    
    
    func drawLine(for point: CGPoint, with length1: CGFloat,_ length2: CGFloat,_ length3: CGFloat) {
        let TL, TR, BL, BR: CGPoint
        
        TL = CGPoint(x: point.x + length1 * cos(angle), y: point.y - length1 * sin(angle))
        TR = CGPoint(x: point.x + (length1 + length2) * cos(angle), y: point.y - (length1 + length2) * sin(angle))
        BL = CGPoint(x: TL.x + length3 * cos((.pi / 2) - angle), y: TL.y + length3 * sin((.pi / 2) - angle))
        BR = CGPoint(x: TR.x + length3 * cos((.pi / 2) - angle), y: TR.y + length3 * sin((.pi / 2) - angle))
        
        let rectangle = UIBezierPath()
        rectangle.move(to: TL)
        rectangle.addLine(to: TR)
        rectangle.addLine(to: BR)
        rectangle.addLine(to: BL)
        rectangle.close()
       
        let layer = CAShapeLayer()
        layer.path = rectangle.cgPath
        layer.fillColor = UIColor.black.cgColor
        linaLayers.append(layer)
        view.layer.addSublayer(layer)
    }

}

private extension UIDevice {
    
    // model identifiers can be found at https://www.theiphonewiki.com/wiki/Models
    static let modelIdentifier: String = {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }()
    
}

private func computeIfSome<T: Any, S: Any>(optional: T?, computation: ((T) -> S)) -> S? { if let some = optional { return computation(some) } else { return .none } }

@available(iOS 9.0, *)
public extension UIScreen {
    
    /// The number of pixels per inch for this device
    static let pixelsPerInch: CGFloat? = {
        switch UIDevice.modelIdentifier {
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":             // iPad 2
            return 132
            
        case "iPad2,5", "iPad2,6", "iPad2,7":                        // iPad Mini
            return 163
            
        case "iPad3,1", "iPad3,2", "iPad3,3":            fallthrough // iPad 3rd generation
        case "iPad3,4", "iPad3,5", "iPad3,6":            fallthrough // iPad 4th generation
        case "iPad4,1", "iPad4,2", "iPad4,3":            fallthrough // iPad Air
        case "iPad5,3", "iPad5,4":                       fallthrough // iPad Air 2
        case "iPad6,7", "iPad6,8":                       fallthrough // iPad Pro (12.9 inch)
        case "iPad6,3", "iPad6,4":                       fallthrough // iPad Pro (9.7 inch)
        case "iPad6,11", "iPad6,12":                     fallthrough // iPad 5th generation
        case "iPad7,1", "iPad7,2":                       fallthrough // iPad Pro (12.9 inch, 2nd generation)
        case "iPad7,3", "iPad7,4":                       fallthrough // iPad Pro (10.5 inch)
        case "iPad7,5", "iPad7,6":                       fallthrough // iPad 6th generation
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": fallthrough // iPad Pro (11 inch)
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": fallthrough // iPad Pro (12.9 inch, 3rd generation)
        case "iPad11,3", "iPad11,4":                                 // iPad Air (3rd generation)
            return 264
            
        case "iPhone4,1":                                fallthrough // iPhone 4S
        case "iPhone5,1", "iPhone5,2":                   fallthrough // iPhone 5
        case "iPhone5,3", "iPhone5,4":                   fallthrough // iPhone 5C
        case "iPhone6,1", "iPhone6,2":                   fallthrough // iPhone 5S
        case "iPhone8,4":                                fallthrough // iPhone SE
        case "iPhone7,2":                                fallthrough // iPhone 6
        case "iPhone8,1":                                fallthrough // iPhone 6S
        case "iPhone9,1", "iPhone9,3":                   fallthrough // iPhone 7
        case "iPhone10,1", "iPhone10,4":                 fallthrough // iPhone 8
        case "iPhone11,8":                               fallthrough // iPhone XR
        case "iPod5,1":                                  fallthrough // iPod Touch 5th generation
        case "iPod7,1":                                  fallthrough // iPod Touch 6th generation
        case "iPad4,4", "iPad4,5", "iPad4,6":            fallthrough // iPad Mini 2
        case "iPad4,7", "iPad4,8", "iPad4,9":            fallthrough // iPad Mini 3
        case "iPad5,1", "iPad5,2":                       fallthrough // iPad Mini 4
        case "iPad11,1", "iPad11,2":                                 // iPad Mini 5
            return 326
            
        case "iPhone7,1":                                fallthrough // iPhone 6 Plus
        case "iPhone8,2":                                fallthrough // iPhone 6S Plus
        case "iPhone9,2", "iPhone9,4":                   fallthrough // iPhone 7 Plus
        case "iPhone10,2", "iPhone10,5":                             // iPhone 8 Plus
            return 401
            
        case "iPhone10,3", "iPhone10,6":                 fallthrough // iPhone X
        case "iPhone11,2":                               fallthrough // iPhone XS
        case "iPhone11,4", "iPhone11,6":                             // iPhone XS Max
            return 458
            
        default:                                                     // unknown model identifier
            return .none
        }
    }()
    
    /// The number of pixels per centimeter for this device
    static let pixelsPerCentimeter: CGFloat? = computeIfSome(optional: pixelsPerInch, computation: { $0 / 2.54 })
    
    static let pointsPerCentimeter: CGFloat? = computeIfSome(optional: pixelsPerCentimeter, computation: { $0 / main.nativeScale })

}

