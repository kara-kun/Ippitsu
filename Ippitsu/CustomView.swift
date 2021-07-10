//
//  CustomView.swift
//  Ippitsu
//
//  Created by 唐津 哲也 on 2021/07/10.
//

import UIKit

class CustomView: UIView, UIScrollViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //imageScrollViewを接続。UIImageViewのインスタンスを設定。
    @IBOutlet weak var imageScrollView: UIScrollView!
    var imageView = UIImageView()
    
    //------------Initiarize and load CustomView-------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib() {
        //CustomViewの部分は各自作成したXibの名前に書き換えてください
        if let view = Bundle.main.loadNibNamed("CustomView", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
    //-------------------------
    override func awakeFromNib() {
        print("awakeFromNib")
        super.awakeFromNib()
        //Declear scrollView delegate and set the background colour.
        imageScrollView.backgroundColor = UIColor.gray
        imageScrollView.delegate = self
        
        //Set imageView as precicely same origin and size to the superview(:scrollView)
        self.imageView.frame = CGRect(x: 0, y: 0, width:imageScrollView.frame.width, height:imageScrollView.frame.height)
        imageView.contentMode = .scaleAspectFill
        imageScrollView.addSubview(imageView)
        
        //Define Zoom scale of scrollView.
        self.imageScrollView.maximumZoomScale = 4.0
        self.imageScrollView.minimumZoomScale = 1.0
        
        //Define Tap-Gesture and add tapGestureRecognizer to scrollView.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.numberOfTapsRequired = 2
        self.imageScrollView.addGestureRecognizer(tapGesture)
    }
    
    //Delegate method for UIScrollViewDelegate protocol(-> return imageView)
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //Method for tap gesture.
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        //タップした時の拡大率として、現在の倍率の二倍と、maximumZoomScaleの比較で小さい方をとる
        let scale = min(imageScrollView.zoomScale * 2, imageScrollView.maximumZoomScale)
        
        //もし拡大率が現在の倍率と一致しなければ
        if scale != imageScrollView.zoomScale {
            //tapPointに画像のタップされた場所を指定。拡大後のサイズをscrollView/スケール。origin位置=(タップされた場所)ー(サイズ/2)
            let tapPoint = sender.location(in: imageView)
            let size = CGSize(width: imageScrollView.frame.width / scale, height: imageScrollView.frame.height / scale)
            let origin = CGPoint(x: tapPoint.x - size.width / 2, y: tapPoint.y - size.height / 2)
            //scrollViewをズームする
            imageScrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
            //すでに最大倍率maximumZoomScaleに達していた場合は、元の大きさ(一倍）に戻す。
        } else {
            imageScrollView.zoom(to: imageScrollView.frame, animated: true)
        }
    }
    
    
}
