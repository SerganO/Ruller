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
    
    let width = UIScreen.main.bounds.size.width
    let height: CGFloat = 100.0
    
    var yBias = 0
    
    var inRec = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            inRec = false
            if pointInRec(locationOfBeganTap){
                print("IN REC")
                inRec = true
            }
            
            
        } else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            
            locationOfEndTap = gestureRecognizer.location(in: view)
        }
        
        guard inRec else {
            return
        }
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        topLeftPoint.y += translation.y
        bottomLeftPoint.y += translation.y
        topRightPoint.y += translation.y
        bottomRightPoint.y += translation.y
        
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
        
        
        
        //gestureRecognizer.view?.transform = gestureRecognizer.view!.transform.translatedBy(x: translation.x, y: translation.y)
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: gestureRecognizer.view!)
    }
    
    @objc func rotate(gestureRecognizer: UIRotationGestureRecognizer) {
        //print("rotate on \(gestureRecognizer.rotation)")
        
        var firstPoint = gestureRecognizer.location(ofTouch: 0, in: view)
        var secondPoint = gestureRecognizer.location(ofTouch: 1, in: view)
        
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            if pointInRec(firstPoint), pointInRec(secondPoint) {
                print("rotate in rec")
            }
        }
        
        
        //gestureRecognizer.view?.transform = gestureRecognizer.view!.transform.rotated(by: gestureRecognizer.rotation)
        gestureRecognizer.rotation = 0
    }
    
    func pointInRec(_ point: CGPoint) -> Bool {
        return point.x >= topLeftPoint.x && point.y >= topLeftPoint.y &&
        point.x <= topRightPoint.x && point.y >= topRightPoint.y &&
        point.x <= bottomRightPoint.x && point.y <= bottomRightPoint.y &&
        point.x >= bottomLeftPoint.x && point.y <= bottomLeftPoint.y
    }


}


