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
    var applyAnimations: [CAAnimation] = []
    var keyFirst: Int = 0 //適用するアニメーションのキーその１
    var keySecond: Int = 0 //適用するアニメーションのキーその２
    var dif: Double = 0.0 //アニメーションに適用する位置情報の差分を格納する変数
    var difArray: [Double] = [] //各文字ごとの位置差分を記録するための配列
    
    //UIView型クラスのイニシャライザ
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //入力された文字列に対して、１文字づつUILabelを作成し、配列labelArrayに格納するメソッドを定義
    func makeLabel() {
        //最初に既存のCAレイヤーをすべて取り除く
        self.layer.removeAllAnimations()
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
        //CALayerの位置をlabelRectの大きさ＊1/2分だけ調整し、bounds.sizeを与える(これをしないと拡大、縮小の中心点がLeft-Topにずれる)
        self.layer.frame.origin = CGPoint(x: self.layer.position.x + labelRect.size.width/2, y: self.layer.position.y +  labelRect.size.height/2)
        self.layer.bounds.size = labelRect.size
    }
    
    //labelを削除するメソッド
    func removeLabel() {
        let subviews = self.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    //REPLAYボタンが押された際のlabel再描写メソッド
    func remakeLabel() {
        //最初にレイヤーをすべて取り除く
        self.layer.removeAllAnimations()
        //前のlabelArrayからUILableを取り出して再配置したのち、新たにremake専用の配列に格納する。
        let font = UIFont(name: fontType, size: CGFloat(fontSize))
        //remake専用のUILabel配列を初期化
        var labels: [UILabel] = []
        //作成済みのlabelArrayの中身UILabelを一つづつ取り出す。
        for label in labelArray {
             let newLabel = UILabel()
             newLabel.text = String(label.text!)
             newLabel.textColor = self.textColor
             newLabel.alpha = 0.0
             newLabel.font = font
             newLabel.sizeToFit()
             newLabel.frame.origin.x = label.frame.origin.x
             newLabel.frame.origin.y =  label.frame.origin.y
             self.addSubview(newLabel) //前と同じ位置に同じパラメータで配置する。
             labels.append(newLabel) //配列labelsに格納する。
         }
         //labelsの中にをlabelArrayに戻す。
         labelArray = labels
        //CALayerの位置をlabelRectの大きさ＊1/2分だけ調整し、bounds.sizeを与える(これをしないと拡大、縮小の中心点がLeft-Topにずれる)
        self.layer.frame.origin = CGPoint(x: self.layer.position.x + labelRect.size.width/2, y: self.layer.position.y +  labelRect.size.height/2)
        self.layer.bounds.size = labelRect.size
    }
    
    //---------アニメーション本体を定義する関数animate（animationIDで複数格納)----------------
    //----------------アニメーション本体を定義する関数animate----------------
    func animate() {
        //文字列をシャッフルするかどうかをランダムに決める
        let flagID = Int.random(in: 0...1)
        if flagID == 1 {
            self.labelArray.shuffle()
        }
        
        //difArrayを空にしておく
        self.difArray = []
        
        //アニメーションテンプレートの配列を取得(仮)
        let temporaryArray = animateType(0.0, 0.0, 0.0, 0.0)
        print("temporaryArray.count: \(temporaryArray.count)")
        
        //残り二つのアニメーションを定義
        keyFirst = Int.random(in: 1...temporaryArray.count - 1)
        keySecond = Int.random(in: 1...temporaryArray.count - 1)
        while keyFirst == keySecond {
            keySecond = Int.random(in: 1...temporaryArray.count - 1)
        }
        
        for i in 0...self.labelArray.count-1 {
            //CAAnimationGroupインスタンスを定義
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = animateDuration
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = false
            
            //difを作ってanimate()メソッドに渡す。あとで使えるように配列に格納する。
            dif = Double.random(in:-300...300)
            self.difArray.append(dif)
            
            //各文字Labelのアンカーポイントを取得
            let anchor_x = labelArray[i].frame.origin.x + labelArray[i].frame.size.width/2
            let anchor_y = labelArray[i].frame.origin.y + labelArray[i].frame.size.height/2
            
            //アニメーションテンプレートの配列を取得
            let array = animateType(anchor_x, anchor_y, eachDuration, dif)
            
            //アニメーショングループに適用するアニメーションを格納し、実行
            animationGroup.animations = [array[0], array[keyFirst], array[keySecond]]
            //終了時の動作(最初の１文字のアニメーションが終了したらanimationDidStopデリゲートを発動)
            if i == 0 {
                animationGroup.delegate = self
            }
            //アニメーションを実行
            animationGroup.beginTime = CACurrentMediaTime() + (eachDuration *  Double(i))
            self.labelArray[i].layer.add(animationGroup, forKey: nil)
        }
    }
    
    //REPLAYボタンが押された時のアニメーション定義メソッド
    func replayAnimate() {
        for i in 0...self.labelArray.count-1 {
            //先に適用されたアニメーションを全て削除する
            //self.labelArray[i].layer.removeAllAnimations()
            //CAAnimationGroupインスタンスを定義
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = animateDuration
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = false
            
            //各文字Labelのアンカーポイントを取得
            let anchor_x = labelArray[i].frame.origin.x + labelArray[i].frame.size.width/2
            let anchor_y = labelArray[i].frame.origin.y + labelArray[i].frame.size.height/2
            
            //アニメーションテンプレートの配列を取得
            let array = animateType(anchor_x, anchor_y, eachDuration, difArray[i])
            applyAnimations = [array[0], array[keyFirst], array[keySecond]]
                        
            //アニメーショングループに適用するアニメーションを格納し、実行
            animationGroup.animations = applyAnimations
            //終了時の動作(最初の１文字のアニメーションが終了したらanimationDidStopデリゲートを発動)
            if i == 0 {
                animationGroup.delegate = self
            }
            //アニメーションを実行
            animationGroup.beginTime = CACurrentMediaTime() + (eachDuration *  Double(i))
            self.labelArray[i].layer.add(animationGroup, forKey: nil)
        }
    }
    
    //------------CAAnimationDelegateプロトコルのデリゲートメソッド実装--------
    //アニメーション終了時の処理
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        //大きさtransition.scaleをX1.1にするアニメーションを設定
        let endAnimation01 = CABasicAnimation(keyPath: "transform.scale")
        endAnimation01.fromValue = 1.0
        endAnimation01.toValue = 1.1
    
        let endAnimationGroup = CAAnimationGroup()
        endAnimationGroup.duration = 2.0
        endAnimationGroup.fillMode = CAMediaTimingFillMode.forwards
        endAnimationGroup.isRemovedOnCompletion = false
        endAnimationGroup.beginTime = CACurrentMediaTime() //アニメーション終了時に起動
        endAnimationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        endAnimationGroup.animations = [endAnimation01]
        self.layer.add(endAnimationGroup, forKey: nil)
    }
    
    //アニメーションのテンプレート
    func animateType(_ anchor_x: CGFloat, _ anchor_y: CGFloat, _ duration: Double, _ differential: Double)-> [CABasicAnimation] {
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
        animation7.byValue = CGPoint(x: 0.0, y: differential)
        animation7.toValue = CGPoint(x: anchor_x, y: anchor_y)
        animation7.duration = duration
        animation7.fillMode = CAMediaTimingFillMode.forwards
        animation7.isRemovedOnCompletion = false
        animateArray.append(animation7)

        //animation8:positionアニメーション(水平方向ランダム)
        let animation8 = CABasicAnimation(keyPath: "position")
        animation8.byValue = CGPoint(x: differential, y: 0.0)
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

