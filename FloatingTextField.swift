//
//  FloatingTextField.swift
//
//  Created by Abhishek.Rathi on 25/04/19.
//  Copyright © 2019 Abhishek.Rathi. All rights reserved.
//

import UIKit

// add new style here, for more customization according to your app design.
enum TextFieldStyle {
    case green
    case red
    case gray
}

@IBDesignable class FloatingTextField: UITextField {
    
    @IBInspectable var errorText: String?
    var noInputHighlightColor: UIColor? = .red
    let placeholderLabel = UILabel()
    let bottomLayer = CAShapeLayer()
    
    var defaultHighlight: UIColor? {
        didSet {
            self.bottomLayer.strokeColor = defaultHighlight!.cgColor
        }
    }
    
    lazy var strokeEndAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    lazy var strokeStartAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.toValue = 0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    override var text: String?{
        willSet{
            self.setStyle(style: .gray)
            self.animatePlaceholderLabelUp()
        }
    }
    
    override func awakeFromNib() {
        
        addSubview(placeholderLabel)
        self.delegate = self
        
        // need these to work animate properly
        self.placeholderLabel.minimumScaleFactor = 0.3
        self.placeholderLabel.adjustsFontSizeToFitWidth = true
        self.placeholderLabel.lineBreakMode = .byClipping
        self.placeholderLabel.numberOfLines = 0
        
        self.placeholderLabel.text = self.placeholder
        self.placeholder?.removeAll()
        
        //Bottom Line CAlayer name
        bottomLayer.name = "bottomLine"
        
        // Change colour
        self.placeholderLabel.font = self.font
        self.placeholderLabel.textColor = .lightGray
        self.borderStyle = .none
        
        animatePlaceHolderLabelDown()
    }
    
    func setStyle(style: TextFieldStyle) {
        layoutIfNeeded()
        
        switch style {
        case .green:
            self.setBottomBorder(color: Constants.darkGreenFV)
            animatePlaceholderLabelUp()
            
        case .gray:
            self.setBottomBorder(color: .lightGray)
            self.placeholderLabel.textColor = .lightGray
            
        case .red:
            self.setBottomBorder(color: #colorLiteral(red: 1, green: 0.1511251674, blue: 0.08996533756, alpha: 0.8503050086))
            self.placeholderLabel.textColor = .red
        }
        
    }
    
    func showWrongInput() {
        
        //TODO:- ErrorText shows to hint user.
        if false {
            let errorLabel = UILabel()
            errorLabel.font = self.font
            errorLabel.minimumScaleFactor = 0.2
            errorLabel.adjustsFontSizeToFitWidth = true
            errorLabel.lineBreakMode = .byClipping
            errorLabel.numberOfLines = 0
            
            errorLabel.text = errorText
            addSubview(errorLabel)
            errorLabel.frame = CGRect(x: 6,
                                      y: self.bounds.maxY,
                                      width: self.bounds.width,
                                      height: 8 )
            
        }
        
        if noInputHighlightColor != nil {
            self.setBottomBorder(color: noInputHighlightColor!)
            self.placeholderLabel.textColor = noInputHighlightColor!
            self.placeholderLabel.alpha = 0.8
            
        }
        else{
            setStyle(style: .red)
        }
    }
    
}

// MARK:- TextField delegate functions.

extension FloatingTextField : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if !Thread.isMainThread {
            print("Called from background thread")
            return
        }
        
        if defaultHighlight != nil {
            self.setBottomBorder(color: defaultHighlight!)
            animatePlaceholderLabelUp()
        }
        else {
            self.setStyle(style: .green)
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.setStyle(style: .gray)
        
        if textField.text == "" {
            
            if noInputHighlightColor != nil {
                self.setBottomBorder(color: noInputHighlightColor!)
            }
            else{
                self.setBottomBorder(color: .red)
            }
            
            animatePlaceHolderLabelDown()
        }
    }
}

// MARK:- Floating Label Animation functions.

extension FloatingTextField {
    
    fileprivate func setBottomBorder(color: UIColor) {
        
        let existingBottomLayer = layer.sublayers?.filter({ layer in
            layer.name == bottomLayer.name })
        
        if (existingBottomLayer?.count)! > 0 {
            guard let bottomShapelayer = existingBottomLayer![0] as? CAShapeLayer else { return }
            bottomShapelayer.strokeColor = color.cgColor
        }
        else {
            
            let bezPath = UIBezierPath()
            bezPath.move(to: CGPoint(x: bounds.minX, y: bounds.maxY + 1))
            bezPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY + 1))
            bottomLayer.path = bezPath.cgPath
            bottomLayer.opacity = 0.8
            bottomLayer.lineCap = .round
            bottomLayer.strokeColor = color.cgColor
            bottomLayer.lineWidth = 0.6
            
            bottomLayer.strokeStart = 0.5
            bottomLayer.strokeEnd = 0.5
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 0.5
            animationGroup.animations = [strokeStartAnimation,strokeEndAnimation]
            animationGroup.isRemovedOnCompletion = false
            animationGroup.fillMode = .forwards
            
            bottomLayer.add(animationGroup, forKey: "strokeAnimation")
            layer.addSublayer(bottomLayer)
        }
    }
    
    fileprivate func animatePlaceholderLabelUp() {
        
        let heightSmall = self.bounds.height * 0.5
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.placeholderLabel.frame = CGRect(x: 0,
                                                     y: self.bounds.minY - heightSmall,
                                                     width: self.bounds.width,
                                                     height: heightSmall )
                self.placeholderLabel.textColor = Constants.darkGreenFV
            })
        }
    }
    
    fileprivate func animatePlaceHolderLabelDown() {
        let heightlarge = self.bounds.height * 0.95
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.placeholderLabel.frame = CGRect(x: 0,
                                                     y: 0,
                                                     width: self.bounds.width,
                                                     height: heightlarge)
            })
        }
    }
}
