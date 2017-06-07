//
//  SoundWaveView.swift
//  swift tap
//
//  Created by Henry on 02/06/2017.
//  Copyright © 2017 Gordon Childs. All rights reserved.
//

import UIKit

typealias SoundCircle = (shape: CAShapeLayer, alpha: CGFloat, scale: CGFloat)

class SoundWaveView: UIView {
    
    private var previousRMS: CGFloat = 0.0
    private var circles = [SoundCircle]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSublayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSublayers()
    }
    
    private func setupSublayers() {
        
        circles.append(SoundCircle(shape: CAShapeLayer(), alpha: 1, scale: 0.15))
        circles.append(SoundCircle(shape: CAShapeLayer(), alpha: 0.7, scale: 0.5))
        circles.append(SoundCircle(shape: CAShapeLayer(), alpha: 0.4, scale: 1.0))
        
        backgroundColor = .clear
        clipsToBounds = false
        updateWavePath()
        
        circles.forEach({
            $0.shape.fillColor = UIColor.white.withAlphaComponent($0.alpha).cgColor
            layer.addSublayer($0.shape)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateWavePath()
    }
    
    private func updateWavePath() {
        circles.forEach({
            $0.shape.path = getPath(scale: 1.0).cgPath
            $0.shape.frame = bounds
        })
    }
    
    func animateSoundLevel(rms: CGFloat) {
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = Double(abs(rms - previousRMS)) / 2
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        circles.forEach({
            animation.fromValue = $0.shape.presentation()?.path
            $0.shape.path = getPath(scale: 1.0 + rms * $0.scale).cgPath
            animation.toValue = $0.shape.path
            $0.shape.add(animation, forKey: "path")
        })
        
        previousRMS = rms
    }
    
    private func getPath(scale: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        return UIBezierPath(arcCenter: center, radius: bounds.midX * scale, startAngle: 0, endAngle: .pi * 2, clockwise: true)
    }
}
