//
//  CustomView.swift
//  Ippitsu
//
//  Created by 唐津 哲也 on 2021/05/29.
//

import UIKit

class CustomWindow: UIView {
    let myLabel = UILabel()
    let view = UIView()
    
    func drawLabel() {
        //myLabel.frame = CGRect(0,0,200,40)
        myLabel.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
