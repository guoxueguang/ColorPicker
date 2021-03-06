//
//  ColorInformationView.swift
//  ColorPicker
//
//  Created by Linsw on 16/12/3.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class ColorInformationView: UIView {

    internal var currentColor = UIColor.white {
        didSet{
            colorIndicationView.backgroundColor = currentColor
            colorComponentsContainerView.color = currentColor
            colorComponentsContainerView.updateColorValue()
        }
    }
    
    private var colorComponentsContainerView : ColorComponentsContainerView!
    private var colorIndicationView : UIView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        colorComponentsContainerView = viewWithTag(2) as! ColorComponentsContainerView
        colorComponentsContainerView.layer.cornerRadius = 10
        colorComponentsContainerView.layer.masksToBounds = true
        
        colorIndicationView = viewWithTag(1)!
        colorIndicationView.layer.cornerRadius = 10
        colorIndicationView.backgroundColor = UIColor.white
        
        // If view is not in tableViewCell
        if (self.tag != -1){
            colorComponentsContainerView.layer.borderColor = UIColor.black.cgColor
            colorComponentsContainerView.layer.borderWidth = 1
            
            colorIndicationView.layer.borderColor = UIColor.black.cgColor
            colorIndicationView.layer.borderWidth = 1
        }
        
        for constraint in constraints where constraint.identifier == "ColorInformationViewHeight" {
            constraint.constant = SizeAdaptation.shared.colorInformationViewHeight
        }
    }
}
