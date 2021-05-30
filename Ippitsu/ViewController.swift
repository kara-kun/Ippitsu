//
//  ViewController.swift
//  Ippitsu
//
//  Created by 唐津 哲也 on 2021/05/28.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var firstTextLabel: UILabel!
    @IBOutlet weak var inputFirstText: UITextField!
    @IBOutlet weak var inputFontTextField: UITextField!
    @IBOutlet weak var fontSlider: UISlider!
    
    //文字の大きさの初期値
    var fontSize: Double = 24
    //使用可能なフォントを入れる配列を用意
    var fontArray: [String] = []
    //フォントの種類
    var fontType: String = ""
    //フォント用ピッカービューの定義
    var pickerView = UIPickerView()

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
        
        //-------------firstTextLabelの初期化------------
        firstTextLabel.textAlignment = NSTextAlignment.center
        firstTextLabel.frame = CGRect(x:0, y:0, width:260, height:100)
        firstTextLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        firstTextLabel.numberOfLines = 1
        firstTextLabel.textColor = UIColor.white
        firstTextLabel.backgroundColor = UIColor.blue
        firstTextLabel.lineBreakMode = NSLineBreakMode.byClipping
        firstTextLabel.adjustsFontSizeToFitWidth = true
        firstTextLabel.text = "Text"
        //firstTextLabel.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
        
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
    
    //--------------画面が描画される際の処理--------------
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //firstTextLabelのテキストを設定
        //フォントの種類を設定
        //フォントfontSizeSliderの値を設定
        
    }
    
    
    //inputFirstTextにテキスト入力されたときの処理
    @IBAction func getFirstText(_ sender: UITextField) {
        //firstTextLabelに、inputFirstTextに入力されたテキストを表示
        firstTextLabel.text = inputFirstText.text!
        //キーボードを消す
        inputFirstText.endEditing(true);
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
    
    @objc func doneFont() {
        self.inputFontTextField.endEditing(true)
    }
    
}

