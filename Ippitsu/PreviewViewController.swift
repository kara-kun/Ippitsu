//
//  PreviewViewController.swift
//  Ippitsu
//
//  Created by 唐津 哲也 on 2021/05/30.
//

import UIKit

class PreviewViewController: UIViewController {
    //ViewControllerからSegueで受け取るパラメーターの初期化
    var writtenText: String = ""
    var fontSize: Double = 18
    var fontType: String = ""
    
    //ImageView接続
    @IBOutlet weak var imageView: UIImageView!
    
    //アニメーションさせる文字列をAnimationLabel型のインスタンスanimationTextとして定義
    let animationText = TextAnimation()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //ViewControllerからSegueでパラメーターの中身が送られてきているか確認(後で消す)
            print("writtenText \(writtenText)")
            print("fontSize \(fontSize)")
            print("fontType \(fontType)")
        //imageViewの背景色を設定（*6/2/2021 とりあえず色は仮です）
        imageView.backgroundColor = UIColor(red: 0.4, green: 0.2, blue: 0.5, alpha: 1)
        
        //animationTextの文字列、フォント、サイズを、入力されたパラメータに設定
        animationText.text = writtenText
        animationText.fontSize = self.fontSize
        animationText.fontType = self.fontType
        
        //animationTextの文字列を設定
        animationText.makeLabel()
        
        //animationTextの位置を決定
        animationText.frame.origin.x = (self.imageView.frame.width / 2) - (animationText.labelRect.width / 2)
        animationText.frame.origin.y = (self.imageView.frame.height / 2) - (animationText.labelRect.height / 2)
        
        //animationTextをviewに追加
        self.imageView.addSubview(animationText)
        //animate()メソッドでアニメーションを実行
        animationText.animate(animationID: 1)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
