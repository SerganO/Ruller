//
//  ViewController.swift
//  Ruller
//
//  Created by Serhii Ostrovetskyi on 9/4/19.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var topLeftPoint = CGPoint()
    var bottomLeftPoint = CGPoint()
    var topRightPoint = CGPoint()
    var bottomRightPoint = CGPoint()
    var lastCenterPoint = CGPoint()
    
    var rec = CAShapeLayer()
    var circle = CAShapeLayer()
    var label = CATextLayer()
    
    let width = UIScreen.main.bounds.size.width
    
    
    let minX: CGFloat = 0
    let minY: CGFloat = 0
    let maxX: CGFloat = UIScreen.main.bounds.size.width
    let maxY: CGFloat = UIScreen.main.bounds.size.height
    
    var drawPoint = CGPoint()
    var drawInArea = false
    
    var angle: CGFloat = 0.0
    let height: CGFloat = 100.0
    
    var panInRec = false
    var rotateInRec = false
    
    
    
    var cm: CGFloat {
        return UIScreen.pointsPerCentimeter ?? 65.0
    }
    
    var mm: CGFloat {
        return cm / 10
    }
    
    var rullerLenght: CGFloat {
        return sqrt((topLeftPoint.x - topRightPoint.x) * (topLeftPoint.x - topRightPoint.x) + (topLeftPoint.y - topRightPoint.y) * (topLeftPoint.y - topRightPoint.y))
    }
    
    var lineLayers = [CAShapeLayer()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(rec)
        for i in 0...Int(UIScreen.main.bounds.size.height / cm) * 2 + 1 {
            let horizontalRec = UIBezierPath()
            let hRec = CAShapeLayer()
            let hTL = CGPoint(x: 0, y: (cm/2) * CGFloat(i))
            let hBL = CGPoint(x: 0, y:  (cm/2) * CGFloat(i) + 1)
            let hTR = CGPoint(x: maxX, y: (cm/2) * CGFloat(i))
            let hBR = CGPoint(x: maxX, y: (cm/2) * CGFloat(i) + 1)
            horizontalRec.move(to: hTL)
            horizontalRec.addLine(to: hTR)
            horizontalRec.addLine(to: hBR)
            horizontalRec.addLine(to: hBL)
            horizontalRec.close()
            hRec.path = horizontalRec.cgPath
            hRec.fillColor = UIColor.black.cgColor
            view.layer.addSublayer(hRec)
        }
        
        for i in 0...Int(width / cm) * 2 + 1{
            let rectangle = UIBezierPath()
            let rec = CAShapeLayer()
            topLeftPoint = CGPoint(x: (cm/2) * CGFloat(i), y: 0)
            bottomLeftPoint = CGPoint(x: (cm/2) * CGFloat(i), y:  maxY)
            topRightPoint = CGPoint(x: (cm/2) * CGFloat(i) + 1, y: 0)
            bottomRightPoint = CGPoint(x: (cm/2) * CGFloat(i) + 1, y: maxY)
            rectangle.move(to: topLeftPoint)
            rectangle.addLine(to: topRightPoint)
            rectangle.addLine(to: bottomRightPoint)
            rectangle.addLine(to: bottomLeftPoint)
            rectangle.close()
            rec.path = rectangle.cgPath
            rec.fillColor = UIColor.black.cgColor
            view.layer.addSublayer(rec)
        }
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(move(gestureRecognizer:)))
        gesture.delegate = self
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate(gestureRecognizer:)))
       // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(gestureRecognizer:)))
        
        rotateGesture.delegate = self
        
        topLeftPoint = CGPoint(x: 0, y: 0)
        bottomLeftPoint = CGPoint(x: 0, y:  height)
        topRightPoint = CGPoint(x: width, y: 0)
        bottomRightPoint = CGPoint(x: width, y: height)
        redrawRulerLayer()
        
        view.addGestureRecognizer(gesture)
        view.addGestureRecognizer(rotateGesture)
        //view.addGestureRecognizer(tapGesture)
        
        let centerPoint = CGPoint(x: topLeftPoint.x + rullerLenght / 2, y: topLeftPoint.y + height / 2)
        lastCenterPoint = centerPoint
        drawLines(centerPoint)
        //rotateAtDegrees(0)
    }
    
//    @objc func tap(gestureRecognizer: UITapGestureRecognizer) {
//        let point = gestureRecognizer.location(in: view)
//        if pointInRec(point) {
//            let currentDegree = round(angle * 180 / .pi)
//            print(angle * 180 / .pi)
//            print(currentDegree)
//            print(Int(currentDegree) % 15)
//            let degree = Int(currentDegree) - Int(currentDegree) % 15
//            angle = CGFloat(degree) + 15
//            rotateAtDegrees(CGFloat(degree + 15))
//        }
//    }
    
    @objc func move(gestureRecognizer: UIPanGestureRecognizer) {
        var locationOfBeganTap: CGPoint
        
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            locationOfBeganTap = gestureRecognizer.location(in: view)
            panInRec = false
            if pointInRec(locationOfBeganTap){
                print("== START PAN IN REC ==")
                panInRec = true
            }
        }
        guard panInRec else {
            drawOnView(gestureRecognizer)
            return
        }
        
        let centerPoint = gestureRecognizer.location(in: view)
        lastCenterPoint = centerPoint
        let length = calculateLenght(for: centerPoint)
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
        redrawRulerLayer()
        
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: gestureRecognizer.view!)
        
        drawLines(centerPoint)
    }
    
    @objc func rotate(gestureRecognizer: UIRotationGestureRecognizer) {
        let firstPoint = gestureRecognizer.location(ofTouch: 0, in: view)
        let secondPoint = gestureRecognizer.location(ofTouch: 1, in: view)
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            rotateInRec = false
            if pointInRec(firstPoint), pointInRec(secondPoint) {
                print("== START ROTATE IN REC ==")
                rotateInRec = true
                view.layer.addSublayer(circle)
                circle.addSublayer(label)
            }
        }
        
        guard rotateInRec else {
            return
        }
        
        angle = -atan2(secondPoint.y - firstPoint.y, secondPoint.x - firstPoint.x)
        
        let centerPoint = CGPoint(x: (secondPoint.x + firstPoint.x) / 2, y: (firstPoint.y + secondPoint.y) / 2)
        lastCenterPoint = centerPoint
        
        var additionalXBias = abs(height / 2 * cos((.pi / 2) - angle))
        if angle >= 0 {
            additionalXBias = -additionalXBias
        }
        let additionalYBias = height / 2 * sin((.pi / 2) - angle)
        
        let length = calculateLenght(for: centerPoint)
        
        topLeftPoint.x = centerPoint.x - length / 2 * cos(angle) + additionalXBias
        topLeftPoint.y = centerPoint.y + length / 2 * sin(angle) - additionalYBias
        topRightPoint.x = topLeftPoint.x + length * cos(angle)
        topRightPoint.y = topLeftPoint.y - length * sin(angle)
        bottomLeftPoint.x = topLeftPoint.x + height * cos((.pi / 2) - angle)
        bottomLeftPoint.y = topLeftPoint.y + height * sin((.pi / 2) - angle)
        bottomRightPoint.x = bottomLeftPoint.x + length * cos(angle)
        bottomRightPoint.y = bottomLeftPoint.y - length * sin(angle)
        
        redrawRulerLayer()
        gestureRecognizer.rotation = 0
        
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: 20, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circle.path = circlePath.cgPath
        
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UIColor.black.cgColor
        circle.lineWidth = 1.0
        
        drawLines(centerPoint)
        let text = NSString(string: "\(abs(Int(angle * 180 / .pi)))°")
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
        let size = text.size(withAttributes: fontAttributes)
        label.fontSize = 20
        label.foregroundColor = UIColor.black.cgColor
        label.string = text
        label.frame = CGRect(x: centerPoint.x - size.width / 2, y: centerPoint.y - size.height / 2 , width: size.width, height: size.height)
        
        
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            circle.removeFromSuperlayer()
            label.removeFromSuperlayer()
        }
        
    }
    
    
    func drawOnView(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            drawPoint = gestureRecognizer.location(in: view)
            drawInArea = pointInArea(drawPoint)
        } else {
            let inAngle = -atan2(gestureRecognizer.location(in: view).y - drawPoint.y, gestureRecognizer.location(in: view).x - drawPoint.x)
            var secondPoint = gestureRecognizer.location(in: view)
            if drawInArea {
                if inAngle != angle {
                    
                    let x = gestureRecognizer.translation(in: view).x
                    let y = gestureRecognizer.translation(in: view).y
                    let lenght = sqrt(x*x + y*y)
                    var xSign: CGFloat = x * cos(angle) >= 0 ? 1 : -1
                    var ySign: CGFloat = y * sin(angle) <= 0 ? 1 : -1
                    let degree = abs(angle) * 180 / .pi
                    if xSign * ySign < 0 {
                        if degree >= 45 && degree <= 135 {
                            xSign = ySign
                        } else {
                            ySign = xSign
                        }
                    }
                    secondPoint.x = drawPoint.x + lenght * cos(angle) * xSign
                    secondPoint.y = drawPoint.y - lenght * sin(angle) * ySign
                }
            }
            let line = CAShapeLayer()
            let linePath = UIBezierPath()
            linePath.move(to: drawPoint)
            linePath.addLine(to: secondPoint)
            line.path = linePath.cgPath
            line.strokeColor = UIColor.black.cgColor
            line.lineWidth = 5
            line.lineJoin = CAShapeLayerLineJoin.round
            self.view.layer.addSublayer(line)
            drawPoint = secondPoint
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: gestureRecognizer.view!)
        }
        
    }
    
//    func rotateAtDegrees(_ degree: CGFloat) {
//        let centerPoint = lastCenterPoint
//        angle = degree * .pi / 180
//        var additionalXBias = abs(height / 2 * cos((.pi / 2) - angle))
//        if angle >= 0 {
//            additionalXBias = -additionalXBias
//        }
//        let additionalYBias = height / 2 * sin((.pi / 2) - angle)
//
//        let length = calculateLenght(for: centerPoint)
//
//        topLeftPoint.x = centerPoint.x - length / 2 * cos(angle) + additionalXBias
//        topLeftPoint.y = centerPoint.y + length / 2 * sin(angle) - additionalYBias
//        topRightPoint.x = topLeftPoint.x + length * cos(angle)
//        topRightPoint.y = topLeftPoint.y - length * sin(angle)
//        bottomLeftPoint.x = topLeftPoint.x + height * cos((.pi / 2) - angle)
//        bottomLeftPoint.y = topLeftPoint.y + height * sin((.pi / 2) - angle)
//        bottomRightPoint.x = bottomLeftPoint.x + length * cos(angle)
//        bottomRightPoint.y = bottomLeftPoint.y - length * sin(angle)
//
//        redrawRulerLayer()
//        //gestureRecognizer.rotation = 0
//
//        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: 20, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
//        circle.path = circlePath.cgPath
//
//        circle.fillColor = UIColor.clear.cgColor
//        circle.strokeColor = UIColor.black.cgColor
//        circle.lineWidth = 1.0
//
//        drawLines(centerPoint)
//        let text = NSString(string: "\(abs(Int(angle * 180 / .pi)))°")
//        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
//        let size = text.size(withAttributes: fontAttributes)
//        label.fontSize = 20
//        label.foregroundColor = UIColor.black.cgColor
//        label.string = text
//        label.frame = CGRect(x: centerPoint.x - size.width / 2, y: centerPoint.y - size.height / 2 , width: size.width, height: size.height)
//
//
////        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
////            circle.removeFromSuperlayer()
////            label.removeFromSuperlayer()
////        }
//    }
    
    func redrawRulerLayer() {
        let rectangle = UIBezierPath()
        rectangle.move(to: topLeftPoint)
        rectangle.addLine(to: topRightPoint)
        rectangle.addLine(to: bottomRightPoint)
        rectangle.addLine(to: bottomLeftPoint)
        rectangle.close()
        rec.path = rectangle.cgPath
        rec.fillColor = UIColor.lightGray.cgColor
        rec.opacity = 0.4
    }
    
    func calculateLenght(for centerPoint: CGPoint) -> CGFloat {
        
        let fLenght = sqrt((centerPoint.x) * (centerPoint.x) + (centerPoint.y) * (centerPoint.y))
        
        let sLenght = sqrt((centerPoint.x - maxX) * (centerPoint.x - maxX) + (centerPoint.y - maxY) * (centerPoint.y - maxY))
        
        let ffLenght = sqrt((centerPoint.x - maxX) * (centerPoint.x - maxX) + (centerPoint.y) * (centerPoint.y))
        
        let ssLenght = sqrt((centerPoint.x) * (centerPoint.x) + (centerPoint.y - maxY) * (centerPoint.y - maxY))
        
        return (max(fLenght, sLenght, ffLenght, ssLenght) * 2)
    }
    
    func pointInArea(_ point: CGPoint) -> Bool {
        var additionalXBias = abs((height / 2 + 50) * cos((.pi / 2) - angle))
        if angle >= 0 {
            additionalXBias = -additionalXBias
        }
        let additionalYBias = (height / 2 + 50) * sin((.pi / 2) - angle)
        var TL = CGPoint()
        var TR = CGPoint()
        var BL = CGPoint()
        var BR = CGPoint()
        TL.x = lastCenterPoint.x - (rullerLenght + 100) / 2 * cos(angle) + additionalXBias
        TL.y = lastCenterPoint.y + (rullerLenght + 100) / 2 * sin(angle) - additionalYBias
        TR.x = TL.x + (rullerLenght + 100) * cos(angle)
        TR.y = TL.y - (rullerLenght + 100) * sin(angle)
        BL.x = TL.x + (height + 100) * cos((.pi / 2) - angle)
        BL.y = TL.y + (height + 100) * sin((.pi / 2) - angle)
        BR.x = BL.x + (rullerLenght + 100) * cos(angle)
        BR.y = BL.y - (rullerLenght + 100) * sin(angle)
        
        
        let r1 = (TL.x - point.x) * (TR.y - TL.y) - (TR.x - TL.x) * (TL.y - point.y)
        let r2 = (TR.x - point.x) * (BR.y - TR.y) - (BR.x - TR.x) * (TR.y - point.y)
        let r3 = (BR.x - point.x) * (BL.y - BR.y) - (BL.x - BR.x) * (BR.y - point.y)
        let r4 = (BL.x - point.x) * (TL.y - BL.y) - (TL.x - BL.x) * (BL.y - point.y)
        
        return (r1 >= 0 && r2 >= 0 && r3 >= 0 && r4 >= 0) || (r1 <= 0 && r2 <= 0 && r3 <= 0 && r4 <= 0)
    }
    
    
    func pointInRec(_ point: CGPoint) -> Bool {
        let r1 = (topLeftPoint.x - point.x) * (topRightPoint.y - topLeftPoint.y) - (topRightPoint.x - topLeftPoint.x) * (topLeftPoint.y - point.y)
        let r2 = (topRightPoint.x - point.x) * (bottomRightPoint.y - topRightPoint.y) - (bottomRightPoint.x - topRightPoint.x) * (topRightPoint.y - point.y)
        let r3 = (bottomRightPoint.x - point.x) * (bottomLeftPoint.y - bottomRightPoint.y) - (bottomLeftPoint.x - bottomRightPoint.x) * (bottomRightPoint.y - point.y)
        let r4 = (bottomLeftPoint.x - point.x) * (topLeftPoint.y - bottomLeftPoint.y) - (topLeftPoint.x - bottomLeftPoint.x) * (bottomLeftPoint.y - point.y)
        
        return (r1 >= 0 && r2 >= 0 && r3 >= 0 && r4 >= 0) || (r1 <= 0 && r2 <= 0 && r3 <= 0 && r4 <= 0)
    }
    
    func drawLines(_ centerPoint: CGPoint) {
        for layer in lineLayers {
            layer.removeFromSuperlayer()
        }
        lineLayers.removeAll()
        var count = 40
        var cm: CGFloat = 65.0
        var mm: CGFloat = 6.5
        if let pointsPerCentimeter = UIScreen.pointsPerCentimeter {
            cm = pointsPerCentimeter
            mm = cm / 10
            count = Int(rullerLenght / mm)
        }
        
        let point1 = CGPoint(x: centerPoint.x - height/2 * cos((.pi / 2) - angle), y: centerPoint.y - height/2 * sin((.pi / 2) - angle))
        let point2 = CGPoint(x: centerPoint.x + height/2 * cos((.pi / 2) - angle), y: centerPoint.y + height/2 * sin((.pi / 2) - angle))
        
        for i in 0...(count / 2) + 1 {
            var size = height / 6
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
        lineLayers.append(layer)
        view.layer.addSublayer(layer)
    }
    
}
