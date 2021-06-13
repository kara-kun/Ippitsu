//
//  RecordingViewAnimation.swift
//  TEST_textAnimation03
//
//  Created by 唐津 哲也 on 2021/06/09.
//

import AVFoundation
import UIKit

@objc protocol RecViewAnimationDelegate: class {
    @objc optional func recViewDidFinishedToSaveDelegate()        //正常終了時
    @objc optional func recViewDidFinishedWithoutCallToStop()    //録画中のViewサイズが変更された際などの異常終了時
}

protocol Imgs2MovieDelegate: class {
    func imgs2MovieDidFinishedToSaveDelegate()
}

/**
指定したViewに対して動画を保存するクラス
*/
class RecViewAnimation: NSObject, Imgs2MovieDelegate {
    
    weak var delegate: RecViewAnimationDelegate? = nil
    var isRecording = false //録画しているかどうか
    var fps: Int = 0
    var destinationURL: URL?
    
    private var scale: CGFloat?                //1ポイント当たり何ピクセルかを格納
    private var recorder: Imgs2Movie?        //画像から動画を作成するクラスのインスタンス
    private var targetView: UIView?            //対象View
    private var urlOfSavedMovie: URL?        //録画終了時に動画ファイルが保存されたURLを保存する
    private var displayLink: CADisplayLink? //
    private var targetViewSize: CGSize? //対象Viewのサイズ？
    
    static let shared: RecViewAnimation = RecViewAnimation()

    private override init() {
        super.init()
        scale = UIScreen.main.scale            //1ポイント当たり何ピクセルか
    }
    
    /**
    対象Viewの録画を開始する
    - parameter targetView: (UIView)録画対象のView
    - parameter fpsSetting: (Int)録画する際のフレームレート
    - returns : (Bool)録画開始出来たか否か (現在録画中の場合には新たに録画スタートすることは出来ない為falseをreturnする)
    */
    func startRecording(view: UIView, fpsSetting: Int) -> Bool {
        //isRecordingフラグがtrue->録画中ならばエラーを表示
        if isRecording {
            print("[Error] Flag(isRecording) is already true. so it can't start recording.")
            return false    //録画中のためfalseをreturnし終了する
        }
        //初期化の段階で、画面のピクセル数がnil=取得できていなければ、エラーを返して終了。nilでなければ_scaleに代入
        guard let _scale = scale else {
            fatalError("[Error]can't get scale value.")
        }
        
        //ーーーーーここから、録画を開始してtrueを返す処理----------
        isRecording = true    //状態を「録画中」へ変更
        targetView = view    //対象のviewを引数で指定されたviewに設定し、クラスのプロパティに保存
        targetViewSize = view.frame.size
        fps = fpsSetting    //フレームレートを引数で指定されたフレームレートfpsSettingに設定し、クラスのプロパティに保存
        recorder = Imgs2Movie(fpsSetting: fps, size: view.frame.size, scale: _scale)    //動画作成クラスを初期化
        recorder!.delegate = self //delegateはself(RecViewAnimationクラス)
        startCapturingViewImages() //フレームレートに従ってtargetViewの録画を開始する
            print("startRecording()開始 targetViewSize: \(targetViewSize!)")
        return true  //trueを返す
    }
    
    /**
    録画を停止する
    - returns : (Bool)正常に動画の作成及び保存処理が開始されたか (処理の正常終了までは保証しない)
    */
    func stopRecording() -> Bool {
        //すでにisRecordingフラグがfalse->録画は停止している
        if isRecording == false {
            return false    //録画されていない為、保存出来ない。よってnilじゃなくてfalseをReturnする
        }
        //-------------------ここから録画終了処理--------------------
        isRecording = false //isRecordingフラグをfalseに切り替える。
        removeCADiplayLink()    //タイマーを削除する
        //動画作成クラスのインスタンスrecoderがnilでないことを確認。
        guard let _recorder = recorder else {
            fatalError("Error: recorder is nil")
        }
        urlOfSavedMovie = _recorder.finishVideoWriting()    //録画を停止する。ここで保存先URLが返されている
        destinationURL = urlOfSavedMovie
        print("stopRecording()録画終了 urlOfSavedMovie: \(urlOfSavedMovie!)") //この時点ではまだ再生できる状態ではないが、拡張子はmp4になっている。
        return true
    }
    
    /**
    Viewの動画を作成する為のフレーム毎のキャプチャ画像の保存を開始する
    */
    private func startCapturingViewImages() {
        setCADiplayLinkSetting()        //動画の1コマをキャプチャする為のタイマーを生成 (CADiplayLinkを使用)
    }
    
    
    /**
    CADiplayLinkの設定を行う
    */
    private func setCADiplayLinkSetting() {
        // CADisplayLink設定 (preferredFramesPerSecondの設定に従ってupdateがコールされる)
        displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
        //displayLinkがnilでないことを確認。nilでなければ、dlにdisplayLinkを代入
        guard let dl = displayLink else {
            fatalError("[Error]displayLink is nil")
        }
        dl.preferredFramesPerSecond = fps   // FPS設定
        dl.add(to: RunLoop.current, forMode: RunLoop.Mode.common)    //タイマーを開始
    }
    
    /**
    CADiplayLinkのタイマーを削除する
    */
    private func removeCADiplayLink() {
        //displayLinkがnilでないことを確認。nilでなければ、dlにdisplayLinkを代入
        guard let dl = displayLink else {
            fatalError("[Error]displayLink is nil")
        }
        dl.remove(from: RunLoop.current, forMode: RunLoop.Mode.common)    //タイマーを停止
        
    }
    
    /**
    setCADiplayLinkSettingに呼び出されるselector。
    */
    @objc private func update(_ displayLink: CADisplayLink) {
        saveFrameImage()
    }
    
    private func saveFrameImage() {
        
        guard let targetView = targetView else {
            fatalError("Error: targetView is nil")
        }
        
        guard let _recorder = recorder else {
            fatalError("Error: recorder is nil")
        }
        
        guard let imagePerFrame = targetView.getCaptureImageFromView() else {
            fatalError("[Error]can't get image capture.")
        }
        
        //もしimagePerFrameのサイズが当初のviewサイズと異なった場合録画を停止する
        if (targetViewSize != imagePerFrame.size) {
            _ = self.stopRecording()
            self.delegate?.recViewDidFinishedWithoutCallToStop?()    //意図せず録画が終了したことを呼び出し先に通知出来る
            return
        }
        
        _recorder.addImageForVideoWriter(image: imagePerFrame)
        
        
    }

    /**
    動画の保存が終了したことを通知するデリゲードメソッド
    */
    func imgs2MovieDidFinishedToSaveDelegate() {
        //print("imgs2MovieDidFinishedToSaveDelegate")
        
        guard let _urlOfSavedMovie = urlOfSavedMovie else {
            fatalError("[Error]urlOfSavedMovie is nil.")
        }
        print("imgs2MovieDidFinishedToSaveDelegate _urlOfSavedMovie: \(_urlOfSavedMovie)")
        //カメラロールに保存できる形式か確認できた場合
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_urlOfSavedMovie.path) == true {

//           ライブラリへ動画を保存する
//            UISaveVideoAtPathToSavedPhotosAlbum(_urlOfSavedMovie.path, self, nil, nil)
            print("DELEGATE imgs2MovieDidFinishedToSaveDelegate() urlOfSavedMovie.path \(_urlOfSavedMovie.path)")
        } else {
            fatalError("[Error]URL is invalid")
        }
        self.delegate?.recViewDidFinishedToSaveDelegate?()        //動画の保存が終了したことを呼び出し先に通知出来る
    }
}

/**
------------------UIImageの配列から動画へ変換するクラス-----------------------
*/
fileprivate class Imgs2Movie: NSObject {
    
    weak var delegate: Imgs2MovieDelegate? = nil
    var frameRate: Int = 0     // フレームレート (インスタンス作成時に指定した値にて初期化)
    var scale: CGFloat = 0    // 1ポイントが何ピクセルか
    
    private var frameCount: Int    = 0    // 現在のフレームカウント (インスタンス作成時に初期化)
    private let frameCountForEachImage = 1                            //各画像を何フレーム表示するか
    private let tmpDirectoryPath = NSTemporaryDirectory()           //tmpディレクトリを取得
    private let movName = "\(NSUUID().uuidString).mp4"                //ユニークなファイル名を作成
    private let outputURLForMovie: URL?                                //保存先のURLを保存する
    private let moviePixelSize: (width: Int, height: Int)?            //作成するムービーのピクセルサイズを保存する
    private let movieSize: CGSize?                                    //作成するムービーのポイントサイズを保存する
    private let videoWriter: AVAssetWriter?                            //ビデオのWirterを保存する
    private let writerInput: AVAssetWriterInput?                    //writer inputを保存する
    private var adaptor: AVAssetWriterInputPixelBufferAdaptor?        //writer input pixel buffer adaptor
    
    private let queue = DispatchQueue(label: "makingMovie")    //画像から動画への変換を行うスレッド

    /**
    Imgs2Movieクラスの初期化
    - parameter fpsSetting: (Int)動画のフレームレート
    - parameter size: (CGSize)動画のサイズ (後にaddするUIImageと同じSizeであることが好まれる)
    - parameter scale: (CGFloat)1ポイントが何ピクセルか
    */
    init(fpsSetting: Int, size: CGSize, scale: CGFloat) {
        frameRate = fpsSetting    //フレームレートを初期化
        self.scale = scale        //スケールを初期化
        let movPath = tmpDirectoryPath + movName    //保存先のパス(文字列)

        //保存先のURL
        outputURLForMovie = URL(fileURLWithPath: movPath)
        guard let _outputURLForMovie = outputURLForMovie else {
            fatalError("[Error]outputERL is invalid.")
        }
        
        //ビデオのWirter
        do {
            try videoWriter = AVAssetWriter(outputURL: _outputURLForMovie, fileType: AVFileType.mov)
        } catch {
            fatalError("[Error]AVAssetWriter error")
        }
        
        //作成するムービーのサイズを決める (*縦横の長さが16の倍数でないと見た目が残念な動画になるから、めんどくさいことしてます)
        moviePixelSize = size.getPixelSizeForMovie(scale: scale)
        guard let _moviePixelSize = moviePixelSize else {
            fatalError("[Error]moviePixelSize is nil.")
        }
        
        //上で求めたムービーのサイズよりUIImageのサイズ変更が必要。以下はそのサイズ
        movieSize = CGSize(width: CGFloat(_moviePixelSize.width) / scale, height: CGFloat(_moviePixelSize.height) / scale)

        //Outputの設定
        let outputSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: _moviePixelSize.width,
            AVVideoHeightKey: _moviePixelSize.height
        ] as [String : Any]
        
        //writer inputを生成
        writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings as [String : AnyObject])
        
        if writerInput == nil {
            fatalError("[Error] writerInput is nil.")
        }
        
        writerInput!.expectsMediaDataInRealTime = true
        videoWriter!.add(writerInput!)    //writerにwriter inputを設定
        
        adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput!,
            sourcePixelBufferAttributes: [    // source pixel buffer attributesを設定
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: _moviePixelSize.width,
                kCVPixelBufferHeightKey as String: _moviePixelSize.height,
            ]
        )

    }
    

    /**
    動画作成の材料であるUIImageを追加する。1コール1オブジェクトの追加としている。
    - parameter image: (UIImage)動画へ合成する画像
    */
    fileprivate func addImageForVideoWriter(image: UIImage?) {
        
        //UIImage追加1枚目の時のみ行うStart処理
        if frameCount == 0 {
            startVideoWriting()
        }
    
        //動画への変換は別スレッドにて実行する
        queue.async {
            self.appendImageToBufferAdaptor(image: image)    //画像をBufferへ埋め込む
        }
        
    }

    /**
    動画の作成を開始する
    */
    private func startVideoWriting() {
        
        if videoWriter != nil {
            //動画を生成できるか確認
            if (!videoWriter!.startWriting()) {
                print("[Error] videoWriter startWriting is false")    // error
            }
            //動画生成開始
            videoWriter!.startSession(atSourceTime: CMTime.zero)
            print("making movie is started.")
        } else {
            print("[Error] videoWriter is nil")    // error
        }
    }
    
    /**
    AVAssetWriterのBuffer Adaptorへ画像を追加する
    - parameter image: (UIImage)動画へ合成する画像
    */
    private func appendImageToBufferAdaptor(image: UIImage?) {

        //画像をBufferへ埋め込む
        if adaptor != nil {
            
            frameCount += 1         //frameCountを+1する
            
            if (!adaptor!.assetWriterInput.isReadyForMoreMediaData) {
                //expectsMediaDataInRealTimeがtrueの時にBufferへ追加不可能な時にはisReadyForMoreMediaDataがfalseになる
                return
            }
            
            let fps = Int32(frameRate)            //フレームレート
            
            // 動画の時間を生成(その画像の表示する時間/開始時点と表示時間を渡す)
            let frameTime: CMTime = CMTimeMake(value: Int64((frameCount - 1) * frameCountForEachImage), timescale: fps)
            
//            let second = CMTimeGetSeconds(frameTime)    //時間経過を確認(確認用)
//            print("[Progress] \(second)")
            
            //入力画像を動画作成に最適なサイズに切り抜く
            guard let _image = image else {
                fatalError("[Error] UIImage Source is invalid")
            }
            guard let _movieSize = movieSize else {
                fatalError("[Error]movieSize is nil")
            }
            let croppedImage = _image.cropImage(croppedSize: _movieSize)
            
            // CGImageからpixel bufferを生成
            let buffer = self.pixelBufferFromCGImage(cgImage: croppedImage.cgImage!)
            
            // 生成したBufferを追加
            if (!adaptor!.append(buffer, withPresentationTime: frameTime)) {
                // Error!
                print("adaptor Error")
            }
            
        }
    }
    
    /**
    動画の生成を終了する
    */
    fileprivate func finishVideoWriting() -> URL? {
        
        let fps = Int32(frameRate)                // FPS
        
        if writerInput == nil {
            fatalError("[Error]writerInput is nil.")
        }
        
        if videoWriter == nil {
            fatalError("[Error]videoWriter is nil.")
        }

        //別スレッドにて生成中と想定される動画作成処理の終了の予約をする
        queue.async {
            // 動画生成終了
            self.writerInput!.markAsFinished()
            self.videoWriter!.endSession(atSourceTime: CMTimeMake(value: Int64((self.frameCount - 1) * self.frameCountForEachImage), timescale: fps))
            self.videoWriter!.finishWriting(completionHandler: {
                // Finish!
                print("movie created.")
            })
            self.delegate?.imgs2MovieDidFinishedToSaveDelegate()        //動画の保存が終了したことを呼び出し先に通知出来る
        }
        return outputURLForMovie //ここで動画のURLを返している
    }

    /**
    CGImageからpixel bufferを生成する
    
    - parameter cgImage: (CGImage)
    - returns : (CVPixelBuffer)
    */
    private func pixelBufferFromCGImage(cgImage: CGImage) -> CVPixelBuffer {
        
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pxBuffer: CVPixelBuffer? = nil
        
        let width = cgImage.width
        let height = cgImage.height
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32ARGB,
                            options as CFDictionary?,
                            &pxBuffer)
        
        CVPixelBufferLockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
        let pxdata = CVPixelBufferGetBaseAddress(pxBuffer!)
        
        let bitsPerComponent: size_t = 8
        let bytesPerRow: size_t = 4 * width
        
        let rgbColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(cgImage, in: CGRect(x:0, y:0, width:CGFloat(width),height:CGFloat(height)))
        
        CVPixelBufferUnlockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pxBuffer!
    }
}


fileprivate extension UIView {
    
    /**
    対象のViewをキャプチャしUIImageで保存
    
    - returns : キャプチャ画像 (UIImage)
    */
    func getCaptureImageFromView() -> UIImage? {
        
        let contextSize = self.frame.size
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)        //コンテキストを作成
        //self.layer.render(in: UIGraphicsGetCurrentContext()!)                //画像にしたいViewのコンテキストを取得
        
        //元々はself.layer.render(in: UIGraphicsGetCurrentContext()!)にてViewのコンテキストを取得していたが
        //UIView.animateで生成したアニメーションなどをキャプチャできないケースがあったため
        //drawHierarchyメソッドを使用する方法に変更した。
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        
        let captureImage = UIGraphicsGetImageFromCurrentImageContext()        //取得したコンテキストをUIImageに変換
        UIGraphicsEndImageContext()                                            //コンテキストを閉じる
        return captureImage
        
    }
    
    
}

fileprivate extension CGSize {
    /**
    対象のポイントサイズから動画作成に使用するピクセルサイズを求める
    
    - parameter scale: (CGFloat)1ポイントが何ピクセルであるか
    - returns : (pixelWidth: Int, pixelHeight: Int)動画作成に使用するピクセルサイズ
    */
    func getPixelSizeForMovie(scale: CGFloat) -> (width: Int, height: Int) {
        let ruleNum = 16    //規定
        
        //作成するムービーのサイズを決める (*縦横の長さが16の倍数でないと見た目が残念な動画になるからめんどくさいことしてます)
        let pixelWidth = Int(self.width * scale)                //1. 素材の横サイズを画素数に変換しInt型にCastする
        let moviePixelWidth = (pixelWidth / ruleNum) * ruleNum        //2. 横ピクセルサイズを規定の倍数に切り捨て近似する
        let pixelHeight = Int(self.height * scale)                //3. 素材の縦サイズを画素数に変換しInt型にCastする
        let moviePixelHeight = (pixelHeight / ruleNum) * ruleNum    //4. 縦ピクセルサイズを規定の倍数に切り捨て近似する
        
        return (moviePixelWidth, moviePixelHeight)
    }
}

fileprivate extension UIImage {
    
    /**
    対象のUIImageのポイントサイズから動画作成に使用するピクセルサイズを求める
    
    - parameter scale: (CGFloat)1ポイントが何ピクセルであるか
    - returns : (pixelWidth: Int, pixelHeight: Int)動画作成に使用するピクセルサイズ
    */
    func getPixelSizeForMovie(scale: CGFloat) -> (width: Int, height: Int) {
        
        let ruleNum = 16    //規定
        
        //作成するムービーのサイズを決める (*縦横の長さが16の倍数でないと見た目が残念な動画になるからめんどくさいことしてます)
        let pixelWidth = Int(self.size.width * scale)                //1. 素材の横サイズを画素数に変換しInt型にCastする
        let moviePixelWidth = (pixelWidth / ruleNum) * ruleNum        //2. 横ピクセルサイズを規定の倍数に切り捨て近似する
        let pixelHeight = Int(self.size.height * scale)                //3. 素材の縦サイズを画素数に変換しInt型にCastする
        let moviePixelHeight = (pixelHeight / ruleNum) * ruleNum    //4. 縦ピクセルサイズを規定の倍数に切り捨て近似する
        
        return (moviePixelWidth, moviePixelHeight)
        
    }
    
    /**
    対象のUIImageを指定した範囲で抜き出す
    
    - parameter croppedSize: (CGSize)切り取りサイズ
    - returns : (UIImage)切り抜き後のUIImage
    */
    func cropImage(croppedSize: CGSize) -> UIImage {
        
        //1. オリジナルUIImageのサイズ
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        
        //2. 切り抜き後のUIImageのサイズ(縦横4ピクセルづつ足してます。そうしないと左と上に変なノイズが乗るので・・・)
        let croppedWidth = croppedSize.width + 4
        let croppedHeight = croppedSize.height + 4
        
        //3. 1と2より切り抜くRectを求める
        let croppedRect = CGRect(x: (originalWidth - croppedWidth) / 2,
                                 y: (originalHeight - croppedHeight) / 2,
                                 width: croppedWidth,
                                 height: croppedHeight)
        
        UIGraphicsBeginImageContextWithOptions(croppedSize, false, 0.0)        //4. コンテキストを作成
        self.draw(in: croppedRect)            //5. 3で用意したRectに従い切り抜いた絵をコンテキストへ描く
        guard let croppedImage = UIGraphicsGetImageFromCurrentImageContext() else {    //6. コンテキストをUIImageに
            fatalError("[Error] croppedImage is nil")
        }
        UIGraphicsEndImageContext()    //7. コンテキストをClose
        
        return croppedImage
    }
}
