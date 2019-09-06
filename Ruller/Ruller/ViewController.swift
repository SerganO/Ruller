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
    
    var rec = CAShapeLayer()
    var circle = CAShapeLayer()
    
    let rullerPOintRec = CAShapeLayer()
    
    let width = UIScreen.main.bounds.size.width
    let height: CGFloat = 100.0
    
    let minX: CGFloat = 0
    let minY: CGFloat = 0
    let maxX: CGFloat = UIScreen.main.bounds.size.width
    let maxY: CGFloat = UIScreen.main.bounds.size.height
    
     var angle: CGFloat = 0.0
    
    var panInRec = false
    var rotateInRec = false
    
    var cm: CGFloat {
        return UIScreen.pointsPerCentimeter ?? 65.0
    }
    
    var mm: CGFloat {
        return cm / 10
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0...Int(UIScreen.main.bounds.size.height / cm) * 2 + 1 {
            let horizontalRec = UIBezierPath()
            let hRec = CAShapeLayer()
            let hTL = CGPoint(x: 0, y: (cm/2) * CGFloat(i))
            let hBL = CGPoint(x: 0, y:  (cm/2) * CGFloat(i) + 1)
            let hTR = CGPoint(x: UIScreen.main.bounds.size.width, y: (cm/2) * CGFloat(i))
            let hBR = CGPoint(x: UIScreen.main.bounds.size.width, y: (cm/2) * CGFloat(i) + 1)
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
            bottomLeftPoint = CGPoint(x: (cm/2) * CGFloat(i), y:  UIScreen.main.bounds.size.height)
            topRightPoint = CGPoint(x: (cm/2) * CGFloat(i) + 1, y: 0)
            bottomRightPoint = CGPoint(x: (cm/2) * CGFloat(i) + 1, y: UIScreen.main.bounds.size.height)
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

        rotateGesture.delegate = self
        
        let rectangle = UIBezierPath()
        topLeftPoint = CGPoint(x: 0, y: 0)
        bottomLeftPoint = CGPoint(x: 0, y:  height)
        topRightPoint = CGPoint(x: width, y: 0)
        bottomRightPoint = CGPoint(x: width, y: height)
        redrawRulerLayer()
        
        view.addGestureRecognizer(gesture)
        view.addGestureRecognizer(rotateGesture)
        
        let centerPoint = CGPoint(x: topLeftPoint.x + rullerLenght / 2, y: topLeftPoint.y + height / 2)
        order(centerPoint)
    }
    
    @objc func move(gestureRecognizer: UIPanGestureRecognizer) {
        var locationOfBeganTap: CGPoint
        
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            
            locationOfBeganTap = gestureRecognizer.location(in: view)
            panInRec = false
            if pointInRec(locationOfBeganTap){
                print("IN REC")
                panInRec = true
            }
        }
        guard panInRec else {
            return
        }
        
        let centerPoint = gestureRecognizer.location(in: view)
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
        
        order(centerPoint)
    }
    
    func redrawRulerLayer() {
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
        view.layer.addSublayer(rec)
    }
    
    func calculateLenght(for centerPoint: CGPoint) -> CGFloat {
        
        let fLenght = sqrt((centerPoint.x) * (centerPoint.x) + (centerPoint.y) * (centerPoint.y))
        
        let sLenght = sqrt((centerPoint.x - maxX) * (centerPoint.x - maxX) + (centerPoint.y - maxY) * (centerPoint.y - maxY))
        
        let ffLenght = sqrt((centerPoint.x - maxX) * (centerPoint.x - maxX) + (centerPoint.y) * (centerPoint.y))
        
        let ssLenght = sqrt((centerPoint.x) * (centerPoint.x) + (centerPoint.y - maxY) * (centerPoint.y - maxY))
        
        return (max(fLenght, sLenght, ffLenght, ssLenght) * 2)
    }
    
   
    
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
        let r1 = (topLeftPoint.x - point.x) * (topRightPoint.y - topLeftPoint.y) - (topRightPoint.x - topLeftPoint.x) * (topLeftPoint.y - point.y)
        let r2 = (topRightPoint.x - point.x) * (bottomRightPoint.y - topRightPoint.y) - (bottomRightPoint.x - topRightPoint.x) * (topRightPoint.y - point.y)
        let r3 = (bottomRightPoint.x - point.x) * (bottomLeftPoint.y - bottomRightPoint.y) - (bottomLeftPoint.x - bottomRightPoint.x) * (bottomRightPoint.y - point.y)
        let r4 = (bottomLeftPoint.x - point.x) * (topLeftPoint.y - bottomLeftPoint.y) - (topLeftPoint.x - bottomLeftPoint.x) * (bottomLeftPoint.y - point.y)
        
        return (r1 >= 0 && r2 >= 0 && r3 >= 0 && r4 >= 0) || (r1 <= 0 && r2 <= 0 && r3 <= 0 && r4 <= 0)
    }
    
    
    
    func order(_ centerPoint: CGPoint) {
        for layer in linaLayers {
            layer.removeFromSuperlayer()
        }
        linaLayers.removeAll()
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
        
        for i in 0...(count / 2) {
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
        linaLayers.append(layer)
        view.layer.addSublayer(layer)
    }

}
