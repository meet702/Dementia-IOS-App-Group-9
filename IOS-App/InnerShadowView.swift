//
//  InnerShadowView.swift
//  IOS-App
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit

final class InnerShadowView: UIView {

    private let shadowLayer = CAGradientLayer()

    override func layoutSubviews() {
        super.layoutSubviews()

        shadowLayer.frame = bounds
        shadowLayer.colors = [
            UIColor.black.withAlphaComponent(0.35).cgColor,
            UIColor.clear.cgColor
        ]

        shadowLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        shadowLayer.endPoint = CGPoint(x: 0.5, y: 0.6)

        if shadowLayer.superlayer == nil {
            layer.addSublayer(shadowLayer)
        }
    }
}
