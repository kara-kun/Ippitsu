//
//  ViewController.swift
//  Ippitsu
//
//  Created by 唐津 哲也 on 2021/05/28.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //@IBOutlet weak var firstTextLabel: UILabel!
    @IBOutlet weak var inputFirstText: UITextField!
    @IBOutlet weak var inputFontTextField: UITextField!
    @IBOutlet weak var fontSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    //-------------firstTextLabelの初期化------------
    let firstTextLabel = UILabel()
    
    //文字の大きさの初期値
    var fontSize: Double = 18.0
    //使用可能なフォントを入れる配列を用意
    var fontArray: [String] = []
    //フォントの種類
    var fontType: String = ""
    //フォント用ピッカービューの定義
    var pickerView = UIPickerView()
    
    //---------遷移先PreviewViewControllerから呼ばれるメソッド--------
    @IBAction func backToInputText(_ segue: UIStoryboardSegue) {
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //----プロトコルのデリゲートを定義-----
        //TextField
        inputFirstText.delegate = self
        //PickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //使用可能なフォントを取得
        let familyNames : Array = UIFont.familyNames
        let len = familyNames.count
        for i in 0 ..< len {
            let fontFamily = familyNames[i] as String
            let fontNames = UIFont.fontNames(forFamilyName: fontFamily)
            fontArray.append(contentsOf: fontNames)
        }
        //print(fontArray)
        //フォントタイプを取得したフォント配列の最初の要素に設定しておく。
        fontType = fontArray[0]
        print(fontType)
        
        //-------------firstTextLabelの初期化------------
            //print(imageView.frame)
        firstTextLabel.textAlignment = NSTextAlignment.center
        firstTextLabel.frame = CGRect(x: 0, y: 0 , width: self.imageView.frame.width / 1.1, height:100)
        firstTextLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        firstTextLabel.numberOfLines = 1
        firstTextLabel.textColor = UIColor.white
        firstTextLabel.layer.borderColor = CGColor(gray: 0.2, alpha: 1.0)
        firstTextLabel.layer.borderWidth = 1.0
        firstTextLabel.font = UIFont(name:fontType, size: CGFloat(fontSize))
        firstTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        firstTextLabel.adjustsFontSizeToFitWidth = false
        firstTextLabel.text = "Your word will appear here."
        firstTextLabel.layer.position = CGPoint(x: self.imageView.frame.width/2, y:self.imageView.frame.height/2)
        self.imageView.addSubview(firstTextLabel)
        
        //スライダーの値を、設定したfontSizeの初期値(＝24)にする。
        fontSlider.value = Float(fontSize/100)
        
        //ーーーーーーーーーtoolBarの定義ーーーーーーーーーー
        let toolbar = UIToolbar()
        //BarButtonItem「done」のインスタンスを作成
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneFont))
        //toolBarに「done」ボタンを追加
        toolbar.setItems([doneItem], animated: true)
        //toolBarの幅を設定
        toolbar.sizeToFit()
        
        //フォント入力欄inputFontTextFieldの入力インターフェースをpickerViewに設定（キーボードの代わりに）
        self.inputFontTextField.inputView = pickerView
        //同様にフォント入力欄の入力インターフェースpickerViewに、アクセサリーとしてtoolBarを追加
        self.inputFontTextField.inputAccessoryView = toolbar
    }

    //----------inputFirstTextにテキスト入力されたときの処理--------
    @IBAction func getFirstText(_ sender: UITextField) {
        //firstTextLabelに、inputFirstTextに入力されたテキストを表示
        firstTextLabel.text = inputFirstText.text!
        //キーボードを消す
        inputFirstText.endEditing(true);
        //textに入力されたテキストを入れる
        //TextAnimation.text = firstTextLabel.text
    }
    
    //------------------文字サイズ調整(UISlider)----------------
    @IBAction func fontSizeSlider(_ sender: UISlider) {
        //fontSizeSliderスライダーの値をゲット。小数点以下を切り捨てて整数値に変換
        let valueSlider = floor(sender.value * 100)
        //print(valueSlider)
        //得られた値をフォントサイズに代入
        fontSize = Double(valueSlider)
        //そのフォントサイズで、firstTextLabelのテキストを再描写
        firstTextLabel.font =  firstTextLabel.font.withSize(CGFloat(fontSize))
    }
    
    //ーーーーーーーーーフォント選択(pickerView)--------------------
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return fontArray.count
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return fontArray[row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        fontType = fontArray[row]
        self.inputFontTextField.text = fontType
        firstTextLabel.font = UIFont(name:fontType, size: CGFloat(fontSize))
    }
    
    //フォント選択toolBarの「Done」ボタンの処理
    @objc func doneFont() {
        //pickerViewを消す
        self.inputFontTextField.endEditing(true)
    }

    //CREATEボタンが押されたときの処理(Segue)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //遷移先PreviewViewControllerのインスタンスを設定
        let previewViewController = segue.destination as! PreviewViewController
        //現在の文字列を取得
        previewViewController.writtenText = firstTextLabel.text!
        //現在のフォントを取得
        previewViewController.fontSize = self.fontSize
        //現在の文字サイズを取得
        previewViewController.fontType = self.fontType
            print(previewViewController.writtenText)
            print(previewViewController.fontSize)
            print(previewViewController.fontType)
    }
    
}

