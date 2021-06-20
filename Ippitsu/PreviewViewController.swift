//
//  PreviewViewController.swift
//  Ippitsu
//
//  Created by 唐津 哲也 on 2021/05/30.
//

import UIKit
import SVProgressHUD

class PreviewViewController: UIViewController, RecViewAnimationDelegate {
    //ViewControllerからSegueで受け取るパラメーターの初期化
    var writtenText: String = ""
    var fontSize: Double = 18
    var fontType: String = ""
    
    //HUDの表示
    var statusHUD = NSLocalizedString("Exporting...", comment: "")
    var failourHUD = NSLocalizedString("Export failed.", comment: "")
    
    //ImageView接続
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var replayBTN: UIButton!
    @IBOutlet weak var randomBTN: UIButton!
    @IBOutlet weak var exportBTN: UIButton!
    
    //アニメーションさせる文字列をAnimationLabel型のインスタンスanimationTextとして定義
    let animationText = TextAnimation()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //ViewControllerからSegueでパラメーターの中身が送られてきているか確認
            print("writtenText \(writtenText)")
            print("fontSize \(fontSize)")
            print("fontType \(fontType)")
    
    }
    
    //ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //ーーーーーーーーー背景色、適用するアニメーションをランダムに決定------------
        
        //let animationText = TextAnimation()
        //背景色を決定
        let backGround = backgroundImage()
        imageView.backgroundColor = backGround
        //(仮設パラメーター)imageViewの背景色を仮決定（*6/2/2021 あとで消す）
        //imageView.backgroundColor = UIColor(red: 0.4, green: 0.2, blue: 0.5, alpha: 1)
        
        //animationTextの文字列、フォント、サイズを、入力されたパラメータに設定
        animationText.text = writtenText
        animationText.fontSize = self.fontSize
        animationText.fontType = self.fontType
        
        //animationTextの文字列を設定
        animationText.makeLabel()
        
        //ボタンを無効化する
        if animationText.endAnimationFlag == false {
            replayBTN.isEnabled = false
            randomBTN.isEnabled = false
            exportBTN.isEnabled = false
        }
        
        //animationTextの位置を決定
        animationText.frame.origin.x = (self.imageView.frame.width / 2) - (animationText.labelRect.width / 2)
        animationText.frame.origin.y = (self.imageView.frame.height / 2) - (animationText.labelRect.height / 2)
        
        //animationTextをviewに追加
        self.imageView.addSubview(animationText)
        //animate()メソッドでアニメーションを実行
        animationText.animate()
        
        //5.5秒後にボタンを有効化する(本当は5秒で良いのだが割り込みが入るとたまに遅延するので0.5秒余裕加える)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            if self.animationText.endAnimationFlag == true {
                self.replayBTN.isEnabled = true
                self.randomBTN.isEnabled = true
                self.exportBTN.isEnabled = true
            }
        }
    }
    
    //「RANDOMIZE」ボタンが押された際の処理 *アニメーション、背景色を再度ランダマイズする。
    @IBAction func btnRandomize(_ sender: Any) {
        animationText.removeLabel()
        //imageViewから前のテキストを削除
        animationText.removeFromSuperview()

        //背景色を再度決定
        let backGround = backgroundImage()
        imageView.backgroundColor = backGround
        
        //labelArrayを空にする。
        animationText.labelArray.removeAll()
        animationText.labelArray = []

        //animationTextの文字列、フォント、サイズを、入力されたパラメータに設定
        animationText.text = writtenText
        animationText.fontSize = self.fontSize
        animationText.fontType = self.fontType

        //animationTextの文字列を設定
        animationText.makeLabel()
        //ボタンを無効化する
        if animationText.endAnimationFlag == false {
            replayBTN.isEnabled = false
            randomBTN.isEnabled = false
            exportBTN.isEnabled = false
        }
        //animationTextの位置を決定
        animationText.frame.origin.x = (self.imageView.frame.width / 2) - (animationText.labelRect.width / 2)
        animationText.frame.origin.y = (self.imageView.frame.height / 2) - (animationText.labelRect.height / 2)

        //animationTextをviewに追加
        self.imageView.addSubview(animationText)
        //animate()メソッドでアニメーションを実行
        animationText.animate()
        
        //5.5秒後にボタンを有効化する(本当は5秒で良いのだが割り込みが入るとたまに遅延するので0.5秒余裕加える)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            if self.animationText.endAnimationFlag == true {
                self.replayBTN.isEnabled = true
                self.randomBTN.isEnabled = true
                self.exportBTN.isEnabled = true
            }
        }
    }
    
    //REPLAYボタンが押された際の処理
    @IBAction func replay(_ sender: Any) {
        animationText.removeLabel()
        //imageViewから前のテキストを削除
        animationText.removeFromSuperview()
        //ラベルを際配置
        animationText.remakeLabel()
        //ボタンを無効化する
        if animationText.endAnimationFlag == false {
            replayBTN.isEnabled = false
            randomBTN.isEnabled = false
            exportBTN.isEnabled = false
        }

        animationText.frame.origin.x = (self.imageView.frame.width / 2) - (animationText.labelRect.width / 2)
        animationText.frame.origin.y = (self.imageView.frame.height / 2) - (animationText.labelRect.height / 2)
        //replayTextAnimationをviewに追加
        imageView.addSubview(animationText)
        //replayTextAnimationのアニメーションを実行
        animationText.replayAnimate()
        //5.5秒後にボタンを有効化する(本当は5秒で良いのだが割り込みが入るとたまに遅延するので0.5秒余裕加える)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            if self.animationText.endAnimationFlag == true {
                self.replayBTN.isEnabled = true
                self.randomBTN.isEnabled = true
                self.exportBTN.isEnabled = true
            }
        }
    }
    
    @IBAction func export(_ sender: Any) {
        animationText.removeLabel()
        //imageViewから前のテキストを削除
        animationText.removeFromSuperview()

        //レコーダーのインスタンスを設定
        let recorder = RecViewAnimation.shared
        recorder.delegate = self

        //REPLAYと同じ処理でアニメーションする手前までを実施
        animationText.remakeLabel()
        //ボタンを無効化する
        if animationText.endAnimationFlag == false {
            replayBTN.isEnabled = false
            randomBTN.isEnabled = false
            exportBTN.isEnabled = false
        }
        animationText.frame.origin.x = (self.imageView.frame.width / 2) - (animationText.labelRect.width / 2)
        animationText.frame.origin.y = (self.imageView.frame.height / 2) - (animationText.labelRect.height / 2)
        //replayTextAnimationをviewに追加
        imageView.addSubview(animationText)

        //記録開始
        let startRecord = recorder.startRecording(view: imageView, fpsSetting: 30)
        //正常に録画が開始されたら
        if startRecord == true {
            //SVProgressHUDを表示
            SVProgressHUD.show(withStatus: statusHUD)
            //文字列が表示されない状態で0.5秒間待つ
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //replayTextAnimationのアニメーションを実行
                self.animationText.replayAnimate()
            }
        } else {
            SVProgressHUD.showError(withStatus: failourHUD)
            return
        }

        //5秒で録画を停止する。
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            let stopRecording = recorder.stopRecording()
            //正常に録画が終了していたら
            if stopRecording == true {
                //SVProgressHUDを消す
                SVProgressHUD.dismiss()
                //保存された動画を処理するActivityViewControllerを立ち上げる
                if let fileURL = recorder.destinationURL {
                    let controller = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                    //activeViewControllerから除外する機能を指定
                    controller.excludedActivityTypes = [
                            .addToReadingList,
                            .assignToContact,
                            .mail,
                            .markupAsPDF,
                            .openInIBooks,
                            .postToFacebook,
                            .postToFlickr,
                            .postToTencentWeibo,
                            .postToVimeo,
                            .postToWeibo,
                            .print,
                        ]
                    
                    //activityViewControllerがdismissされた際のハンドラーを定義＝書き出した動画をtmpから削除してストレージを解放
                    controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                        //ボタンを有効化する
                        if self.animationText.endAnimationFlag == true {
                            self.replayBTN.isEnabled = true
                            self.randomBTN.isEnabled = true
                            self.exportBTN.isEnabled = true
                        }
                        
                        if !completed {
                            // User canceled
                            print("キャンセルされました")
                            //tmpムービーの削除
                            do {
                                try FileManager.default.removeItem(at: fileURL)
                            } catch {
                                print("動画を削除できませんでした：　\(error.localizedDescription)")
                                return
                            }
                            return
                        }
                        // User completed activity
                        print("ActivityViewControllerの操作が完了しました")
                        //tmpムービーの削除
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            print("動画を削除できませんでした：　\(error.localizedDescription)")
                            return
                        }
                        return
                    }
                    //ActivityViewControllerの表示
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
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
