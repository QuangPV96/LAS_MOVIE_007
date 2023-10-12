//
//  BorderView.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import UIKit

class BorderView: UIView {
    
    // Thuộc tính để thiết lập bán kính của từng góc
    @IBInspectable var topLeftCornerRadius: CGFloat = 0.0
    @IBInspectable var topRightCornerRadius: CGFloat = 0.0
    @IBInspectable var bottomLeftCornerRadius: CGFloat = 0.0
    @IBInspectable var bottomRightCornerRadius: CGFloat = 0.0
    
    // Thuộc tính để thiết lập độ dày của đường viền
    @IBInspectable var borderWidth: CGFloat = 0.0
    
    // Thuộc tính để thiết lập màu sắc của đường viền
    @IBInspectable var borderColor: UIColor = UIColor.clear
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Tạo một đối tượng UIBezierPath để bo góc tùy chỉnh
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX + topLeftCornerRadius, y: bounds.minY))
        
        // Thêm các đoạn đường để bo góc
        path.addLine(to: CGPoint(x: bounds.maxX - topRightCornerRadius, y: bounds.minY))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - topRightCornerRadius, y: bounds.minY + topRightCornerRadius),
                    radius: topRightCornerRadius,
                    startAngle: CGFloat(-Double.pi / 2),
                    endAngle: 0,
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - bottomRightCornerRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - bottomRightCornerRadius, y: bounds.maxY - bottomRightCornerRadius),
                    radius: bottomRightCornerRadius,
                    startAngle: 0,
                    endAngle: CGFloat(Double.pi / 2),
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: bounds.minX + bottomLeftCornerRadius, y: bounds.maxY))
        path.addArc(withCenter: CGPoint(x: bounds.minX + bottomLeftCornerRadius, y: bounds.maxY - bottomLeftCornerRadius),
                    radius: bottomLeftCornerRadius,
                    startAngle: CGFloat(Double.pi / 2),
                    endAngle: CGFloat(Double.pi),
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + topLeftCornerRadius))
        path.addArc(withCenter: CGPoint(x: bounds.minX + topLeftCornerRadius, y: bounds.minY + topLeftCornerRadius),
                    radius: topLeftCornerRadius,
                    startAngle: CGFloat(Double.pi),
                    endAngle: CGFloat(-Double.pi / 2),
                    clockwise: true)
        
        path.close()
        
        // Tạo layer mask để áp dụng bo góc
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        layer.masksToBounds = true
        
        // Thiết lập đường viền
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        
    }
    
}
