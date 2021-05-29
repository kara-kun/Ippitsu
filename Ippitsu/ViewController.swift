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
    @IBOutlet weak var fontPickerView: UIPickerView!
    

    //文字の大きさの初期値
    var fontSize: Double = 24
    //使用可能なフォントを入れる配列を用意
    var fontArray: [String] = []
    //フォントの種類
    var fontType: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //----プロトコルのデリゲートを定義
        //TextField
        inputFirstText.delegate = self
        //PickerView
        fontPickerView.delegate = self
        fontPickerView.dataSource = self
        
        //使用可能なフォントを月t
        let familyNames : Array = UIFont.familyNames
        let len = familyNames.count
        for i in 0 ..< len {
            let fontFamily = familyNames[i] as String
            let fontNames = UIFont.fontNames(forFamilyName: fontFamily)
            fontArray.append(contentsOf: fontNames)
        }
        print(fontArray)
        

    }
    
    //テキスト入力されたときの処理
    @IBAction func getFirstText(_ sender: UITextField) {
        //firstTextLabelに入力されたテキストを表示
        firstTextLabel.text = inputFirstText.text!
        //キーボードを消す
        inputFirstText.endEditing(true);
    }
    
    //文字サイズ調整スライダーの処理
    @IBAction func fontSizeSlider(_ sender: UISlider) {
        //スライダーの値をゲットする
        let valueSlider = floor(sender.value * 100)
        //print(valueSlider)
        
        //得られた値をフォントサイズに代入
        fontSize = Double(valueSlider)
        //そのフォントサイズで、firstTextLabelのテキストを再描写
        firstTextLabel.font =  firstTextLabel.font.withSize(CGFloat(fontSize))
    }
    
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
        firstTextLabel.font = UIFont(name:fontType, size: CGFloat(fontSize))
    }
}

