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
    
    let width = UIScreen.main.bounds.size.width
    let height: CGFloat = 100.0
    
    var yBias = 0
    
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
        rec.fillColor = UIColor.red.cgColor
        view.layer.addSublayer(rec)
        
        
        view.addGestureRecognizer(gesture)
        view.addGestureRecognizer(rotateGesture)
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
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        topLeftPoint.y += translation.y
        bottomLeftPoint.y += translation.y
        topRightPoint.y += translation.y
        bottomRightPoint.y += translation.y
        topLeftPoint.x += translation.x
        bottomLeftPoint.x += translation.x
        topRightPoint.x += translation.x
        bottomRightPoint.x += translation.x
        
        
        
        
        
        rec.removeFromSuperlayer()
        let rectangle = UIBezierPath()
        rectangle.move(to: topLeftPoint)
        rectangle.addLine(to: topRightPoint)
        rectangle.addLine(to: bottomRightPoint)
        rectangle.addLine(to: bottomLeftPoint)
        rectangle.close()
        rec.path = rectangle.cgPath
        rec.fillColor = UIColor.red.cgColor
        view.layer.addSublayer(rec)

        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: gestureRecognizer.view!)
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
        
        topLeftPoint.x = centerPoint.x - width / 2 * cos(angle) + additionalXBias
        topLeftPoint.y = centerPoint.y + width / 2 * sin(angle) - additionalYBias
        topRightPoint.x = topLeftPoint.x + width * cos(angle)
        topRightPoint.y = topLeftPoint.y - width * sin(angle)
        bottomLeftPoint.x = topLeftPoint.x + height * cos((.pi / 2) - angle)
        bottomLeftPoint.y = topLeftPoint.y + height * sin((.pi / 2) - angle)
        bottomRightPoint.x = bottomLeftPoint.x + width * cos(angle)
        bottomRightPoint.y = bottomLeftPoint.y - width * sin(angle)
        
        
        rec.removeFromSuperlayer()
        let rectangle = UIBezierPath()
        rectangle.move(to: topLeftPoint)
        rectangle.addLine(to: topRightPoint)
        rectangle.addLine(to: bottomRightPoint)
        rectangle.addLine(to: bottomLeftPoint)
        rectangle.close()
        rec.path = rectangle.cgPath
        rec.fillColor = UIColor.red.cgColor
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
    
    func orger() {
        
        
        
    }

}


