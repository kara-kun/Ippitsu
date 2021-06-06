//
//  TextAnimation.swift
//  Ippitsu
//
//  Created by 唐津 哲也 on 2021/06/02.
//

import UIKit

class TextAnimation: UIView, CAAnimationDelegate {
    //ユーザーが決定するパラメータ
    var text: String = ""
    var fontSize: Double = 18.0
    var fontType: String = ""
    var textColor: UIColor = UIColor.red//仮(red: 1, green: 1, blue: 1, alpha: 1)
    var animateDuration : Double = 3.0
    var eachDuration: Double = 0 //１文字あたりのアニメーション継続時間
    var animationDelay : Double = 0.1
    var animationIndex: Int = 0 //各アニメーションを識別するID
    var chaMargin: CGFloat = 0 //文字間はゼロのまま
    var labelRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var labelArray: [UILabel] = []
    var loopCount: Int = 0 //アニメーションが表示が終了しているかを確認する際に使用
    
    //UIView型クラスのイニシャライザ
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //入力された文字列に対して、１文字づつUILabelを作成し、配列labelArrayに格納するメソッドを定義
    func makeLabel() {
        //開始x座標を定義（labelRectのx　と同じ）
        var startx: CGFloat = labelRect.origin.x
            print("startx = \(startx)")
        //文字列全体の幅と高さを計測するための変数
        var labelHeight: CGFloat = CGFloat(0.0)
        var labelWidth: CGFloat = CGFloat(0.0)
        //文字列の色を設定
        textColor = textColorCreate()
        //入力されたフォントと文字サイズを設定
        let font = UIFont(name: fontType, size: CGFloat(fontSize))
        //labelArrayを空にする。
        labelArray = []
        
        //入力された文字列inputTextを、１文字づつ取り出す
        for chr in self.text {
            //UILabel型のインスタンスlabelを定義
            let label = UILabel()
            //labelに titleの文字を１文字づつ順に代入
            label.text = String(chr)
            label.textColor = self.textColor
            label.alpha = 0.0 //文字の不透明度はゼロ＝透明にしておく
            label.font = font
            label.sizeToFit() //各文字の大きさに合わせてlabelのRectSizeを調整
            label.frame.origin.x = startx //文字の位置xを設定
            //文字の表示位置を、「各文字の横幅＋文字間」に設定
            startx += label.frame.width + self.chaMargin
            label.frame.origin.y = labelRect.origin.y
            //文字列の全体の幅を取得しておく
            labelWidth = startx
            //各文字の高さを確認し、最大値を調べる
            if labelHeight < label.frame.height {
                labelHeight = label.frame.height
            }
            
            self.addSubview(label) //以上の状態で、labelを描画する。
            self.labelArray.append(label) //１文字づつUILabelにしたものを、配列labelArrayに格納
            //文字数から、１文字あたりの表示時間を決定する。
            eachDuration = animateDuration / Double(self.labelArray.count)
            //labelRactのサイズを更新する。
            labelRect.size = CGSize(width: labelWidth, height: labelHeight)
        }
    }
    
    //labelを削除するメソッド
    func removeLabel() {
        let subviews = self.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    //---------アニメーション本体を定義する関数animate（animationIDで複数格納)----------------
    //----------------アニメーション本体を定義する関数animate----------------
    func animate() {
        //文字列をシャッフルするかどうかをランダムに決める
        let flagID = Int.random(in: 0...1)
        if flagID == 1 {
            self.labelArray.shuffle()
        }
        
        //アニメーションテンプレートの配列を取得(仮)
        let temporaryArray = animateType(0.0, 0.0, 0.0)
        print("temporaryArray.count: \(temporaryArray.count)")
        
        //残り二つのアニメーションを定義
        let keyFirst = Int.random(in: 1...temporaryArray.count - 1)
        var keySecond = Int.random(in: 1...temporaryArray.count - 1)
        while keyFirst == keySecond {
            keySecond = Int.random(in: 1...temporaryArray.count - 1)
        }
        print("keyFirst\(keyFirst)")
        print("keySecond\(keySecond)")
        
        
        for i in 0...self.labelArray.count-1 {
            //CAAnimationGroupインスタンスを定義
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = animateDuration
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = false
            
            //各文字Labelのアンカーポイントを取得
            let anchor_x = labelArray[i].frame.origin.x + labelArray[i].frame.size.width/2
            let anchor_y = labelArray[i].frame.origin.y + labelArray[i].frame.size.height/2
            
            //アニメーションテンプレートの配列を取得
            let array = animateType(anchor_x, anchor_y, eachDuration)
            
            //アニメーショングループに適用するアニメーションを格納し、実行
            animationGroup.animations = [array[0], array[keyFirst], array[keySecond]]
            //animationGroup.delegate = self
            //アニメーションを実行
            animationGroup.beginTime = CACurrentMediaTime() + (eachDuration *  Double(i))
            self.labelArray[i].layer.add(animationGroup, forKey: nil)
            //loopCountに1足す（最終的にはself.labelArray.countになるはず）
            //loopCount += 1
        }
    }
    //------------CAAnimationDelegateプロトコルのデリゲートメソッド実装--------
    //アニメーション終了時の処理
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        print("flag: \(flag)")
//        print("self.layer.bounds \(self.layer.bounds)")
//        print("self.layer.position \(self.layer.position)")
//        print("labelRect.origin\(labelRect.origin)")
//        print("self.layer.frame \(self.layer.frame)")
//        print("self.layer.anchorPoint \(self.layer.anchorPoint)")
//
//
//        while loopCount != self.labelArray.count {
//            if flag == true {
//                loopCount += 1
//            }
//        //不透明度を1->０にするアニメーションを設定
//        let animationEnd = CABasicAnimation(keyPath: "transform.scale")
//        animationEnd.fromValue = 1.0
//        animationEnd.toValue = 0.0
//
//        animationEnd.duration = 5.0
//        animationEnd.fillMode = CAMediaTimingFillMode.forwards
//        animationEnd.isRemovedOnCompletion = false
//        //animationEnd.delegate = self
//        //animationEnd.beginTime = CACurrentMediaTime() + 1.0 //アニメーション終了から4秒後に起動
//            print("End.beginTime \(animationEnd.beginTime)")
//            print(flag)
//            print("CAAnimation:\(anim)")
//        self.layer.add(animationEnd, forKey: nil)
//        }
//    }
    
    //アニメーションのテンプレート
    func animateType(_ anchor_x: CGFloat, _ anchor_y: CGFloat, _ duration: Double)-> [CABasicAnimation] {
        //let anchor_x: CGFloat = 0.0
        //let anchor_y: CGFloat = 0.0
        var animateArray: [CABasicAnimation] = [] //アニメーションのテンプレートを格納する配列
        //animation0:不透明度を0->1へ変えるアニメーション＊これは必ずGroupに適用すること！！
        let animation0 = CABasicAnimation(keyPath: "opacity")
        animation0.fromValue = 0.0
        animation0.toValue = 1.0
        animation0.duration = duration
        animation0.fillMode = CAMediaTimingFillMode.forwards
        animation0.isRemovedOnCompletion = false
        animateArray.append(animation0)

        //animation1:スケールを0->X1へ変えるアニメーション
        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.fromValue = 0.0
        animation1.toValue = 1.0
        animation1.duration = duration
        animation1.fillMode = CAMediaTimingFillMode.forwards
        animation1.isRemovedOnCompletion = false
        animateArray.append(animation1)

        //animation2:スケールをX5->X1へ変えるアニメーション
        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.fromValue = 5.0
        animation2.toValue = 1.0
        animation2.duration = duration
        animation2.fillMode = CAMediaTimingFillMode.forwards
        animation2.isRemovedOnCompletion = false
        animateArray.append(animation2)

        //animation3:x軸2回転アニメーション
        let animation3 = CABasicAnimation(keyPath: "transform.rotation.x")
        animation3.fromValue = .pi * 2.0
        animation3.toValue = 0.0
        animation3.duration = duration
        animation3.fillMode = CAMediaTimingFillMode.forwards
        animation3.isRemovedOnCompletion = false
        animateArray.append(animation3)

        //animation4:y軸回転アニメーション
        let animation4 = CABasicAnimation(keyPath: "transform.rotation.y")
        animation4.fromValue = .pi * 0.5
        animation4.toValue = 0.0
        animation4.duration = duration
        animation4.fillMode = CAMediaTimingFillMode.forwards
        animation4.isRemovedOnCompletion = false
        animateArray.append(animation4)

        //animation:z軸2回転アニメーション
        let animation5 = CABasicAnimation(keyPath: "transform.rotation.z")
        animation5.fromValue = .pi * 2.0
        animation5.toValue = 0.0
        animation5.duration = duration
        animation5.fillMode = CAMediaTimingFillMode.forwards
        animation5.isRemovedOnCompletion = false
        animateArray.append(animation5)

        //animation6:positionアニメーション(垂直方向一定（上から）)
        let animation6 = CABasicAnimation(keyPath: "position")
        animation6.byValue = CGPoint(x: 0.0, y: 100.0)
        animation6.toValue = CGPoint(x: anchor_x, y: anchor_y)
        animation6.duration = duration
        animation6.fillMode = CAMediaTimingFillMode.forwards
        animation6.isRemovedOnCompletion = false
        animateArray.append(animation6)

        //animation7:positionアニメーション(垂直方向ランダム)
        let animation7 = CABasicAnimation(keyPath: "position")
        let difY = Double.random(in: -300...300)
        animation7.byValue = CGPoint(x: 0.0, y: difY)
        animation7.toValue = CGPoint(x: anchor_x, y: anchor_y)
        animation7.duration = duration
        animation7.fillMode = CAMediaTimingFillMode.forwards
        animation7.isRemovedOnCompletion = false
        animateArray.append(animation7)

        //animation8:positionアニメーション(水平方向ランダム)
        let animation8 = CABasicAnimation(keyPath: "position")
        let difX = Double.random(in: -300...300)
        animation8.byValue = CGPoint(x: difX, y: 0.0)
        animation8.toValue = CGPoint(x: anchor_x, y: anchor_y)
        animation8.duration = duration
        animation8.fillMode = CAMediaTimingFillMode.forwards
        animation8.isRemovedOnCompletion = false
        animateArray.append(animation8)

        //animation9:positionアニメーション(水平方向一定(fromLEFT))
        let animation9 = CABasicAnimation(keyPath: "position")
        animation9.byValue = CGPoint(x: 300, y: 0.0)
        animation9.toValue = CGPoint(x: anchor_x, y: anchor_y)
        animation9.duration = duration
        animation9.fillMode = CAMediaTimingFillMode.forwards
        animation9.isRemovedOnCompletion = false
        animateArray.append(animation9)

        return animateArray
    }
    
}

public func backgroundImage() -> UIColor {
    let blueBG = UIColor(red: 0.0, green: 0.0, blue: 0.4, alpha: 1.0)
    let redBG = UIColor(red: 0.4, green: 0.0, blue: 0.0, alpha: 1.0)
    let greenBG = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
    let cyanBG = UIColor(red: 0.0, green: 0.4, blue: 0.4, alpha: 1.0)
    let yellowBG = UIColor(red: 0.4, green: 0.4, blue: 0.0, alpha: 1.0)
    let magentaBG = UIColor(red: 0.4, green: 0.0, blue: 0.4, alpha: 1.0)
    let blackBG = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    let colorBG: [UIColor] = [blueBG, redBG, greenBG, cyanBG, yellowBG, magentaBG, blackBG,]
    
    let backGround: UIColor = colorBG[Int.random(in: 0...colorBG.count - 1)]
    return backGround
}

public func textColorCreate() -> UIColor {
    let blueTX = UIColor(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
    let redTX = UIColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 1.0)
    let greenTX = UIColor(red: 0.7, green: 1.0, blue: 0.7, alpha: 1.0)
    let cyanTX = UIColor(red: 0.7, green: 1.0, blue: 1.0, alpha: 1.0)
    let yellowTX = UIColor(red: 1.0, green: 1.0, blue: 0.7, alpha: 1.0)
    let magentaTX = UIColor(red: 1.0, green: 0.7, blue: 1.0, alpha: 1.0)
    let whiteTX = UIColor.white
    
    let colorTX: [UIColor] = [blueTX, redTX, greenTX, cyanTX, yellowTX, magentaTX, whiteTX,]
    
    let textColor: UIColor = colorTX[Int.random(in: 0...colorTX.count - 1)]
    return textColor
}

//配列（文字）をシャッフルする拡張メソッド
extension Array {
    mutating func shuffle() {
        for i in 0 ..< self.count {
            let j = Int.random(in: 0 ..< self.count)
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
    
    var shuffled: Array {
        var temp = Array<Element>(self)
        temp.shuffle()
        return temp
    }
}

