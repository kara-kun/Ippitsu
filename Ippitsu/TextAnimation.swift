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
    var loopCount : Int = 0
    var animateDuration : Double = 3.0
    var eachDuration: Double = 0 //１文字あたりのアニメーション継続時間
    var animationDelay : Double = 0.1
    var animationIndex: Int = 0 //各アニメーションを識別するID
    var chaMargin: CGFloat = 0 //文字間はゼロのまま
    var labelRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var labelArray: [UILabel] = []
    
    //入力された文字列に対して、１文字づつUILabelを作成し、配列labelArrayに格納するメソッドを定義
    func makeLabel() {
        //開始x座標を定義（labelRectのx　と同じ）
        var startx: CGFloat = labelRect.origin.x
            print("startx = \(startx)")
        //文字列全体の幅と高さを計測するための変数
        var labelHeight: CGFloat = CGFloat(0.0)
        var labelWidth: CGFloat = CGFloat(0.0)
        
        //入力されたフォントと文字サイズを設定
        let font = UIFont(name: fontType, size: CGFloat(fontSize))
        
        //入力された文字列inputTextを、１文字づつ取り出す
        for chr in self.text {
            //UILabel型のインスタンスlabelを定義
            let label = UILabel()
            //labelに titleの文字を１文字づつ順に代入
            label.text = String(chr)
            label.textColor = self.textColor
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
            
            label.alpha = 0 //文字の不透明度はゼロ＝透明にしておく
            self.addSubview(label) //以上の状態で、labelを描画する。
            //１文字づつUILabelにしたものを、配列labelArrayに格納
            self.labelArray.append(label)
            //文字数から、１文字あたりの表示時間を決定する。
            eachDuration = animateDuration / Double(self.labelArray.count)
            //labelRactのサイズを更新する。
            labelRect.size = CGSize(width: labelWidth, height: labelHeight)
        }
    }
    
    //---------アニメーション本体を定義する関数animate（animationIDで複数格納)----------------
    func animate(animationID: Int) {
        //---------各アニメーションをanimationID毎に定義-------------
        //animationID=1の場合(フェードイン＋シャッフル)
        if animationID == 1 {
            //文字列のシャッフルを実行
            self.labelArray.shuffle()
            //文字数分おなじアニメーションをくりかえず
            for i in 0...self.labelArray.count - 1 {
                //CAAnimationGroupインスタンスを定義
                let animationGroup = CAAnimationGroup()
                animationGroup.duration = animateDuration
                animationGroup.fillMode = CAMediaTimingFillMode.forwards
                animationGroup.isRemovedOnCompletion = false
                
                //ID=1のアニメーション(animation1:不透明度を0->1へ変えるアニメーション）)
                let animation1 = CABasicAnimation(keyPath: "opacity")
                animation1.fromValue = 0.0
                animation1.toValue = 1.0
                animation1.duration = eachDuration
                animation1.fillMode = CAMediaTimingFillMode.forwards
                animation1.isRemovedOnCompletion = false
                //animation1をanimationGroupに適用
                animationGroup.animations = [animation1]
                animationGroup.delegate = self
                //アニメーションを実行
                animationGroup.beginTime = CACurrentMediaTime() + (eachDuration *  Double(i))
                self.labelArray[i].layer.add(animationGroup, forKey: nil)
                    //確認用ログ
                    print("i \(i)")
                    print("labelArray[i] \(labelArray[i].text!)")
                    print("animationGroup.beginTime \(animationGroup.beginTime)")
            }
        }
    }
    //------------CAAnimationDelegateプロトコルのデリゲートメソッド実装--------
    //アニメーション終了時の処理
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            //不透明度を1->０にするアニメーションを設定
            let animationEnd = CABasicAnimation(keyPath: "opacity")
            animationEnd.fromValue = 1.0
            animationEnd.toValue = 0.0
            animationEnd.duration = 2.0
            animationEnd.fillMode = CAMediaTimingFillMode.forwards
            animationEnd.isRemovedOnCompletion = false
            //animationEnd.delegate = self
            animationEnd.beginTime = CACurrentMediaTime() + 4.0//アニメーション終了から4秒後に起動
                print("CAAnimation:\(anim)")
                print("flag:\(flag)")
                print("animationEnd.beginTime:\(animationEnd.beginTime)")
            self.layer.add(animationEnd, forKey: nil)
    }
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

