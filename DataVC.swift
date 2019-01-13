//
//  DataVC.swift
//  hastaneproje
//
//  Created by Caner Altuner on 2.12.2018.
//  Copyright © 2018 Caner Altuner. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class DataVC: UIViewController,UITextFieldDelegate {

    private let dataSource = ["Gribal Enfeksiyon","Zatüre","Kızamık","Su Çiçeği","Kanser","Egzama"]
    
    @IBOutlet weak var hastaAdText: UITextField!
    @IBOutlet weak var hastaTCNOtext: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var hastalikLabel: UILabel!
    @IBOutlet weak var ilaclarText: UITextField!
    @IBOutlet weak var ekNotText: UITextField!
    @IBOutlet weak var tarihLabel: UILabel!
    let doktor = Auth.auth().currentUser?.email!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        hastaTCNOtext.delegate = self
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 50
            }
        }
    }
    
    @objc func keyboardWillShowAlt(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    @IBAction func ilaclarText(_ sender: Any) {

    }
    
    @IBAction func eknotText(_ sender: Any) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //maxLenght adında bir değişken oluşturuyoruz ve içine 11 sayısını giriyoruz.
        //Bu sayıyı textbox'un lenght'i olarak atıyoruz böylece tcno 11 haneden fazla girilemiyor.
        let maxLength = 11
        let currentString: NSString = hastaTCNOtext.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @IBAction func dataSaveClicked(_ sender: Any) {
        if hastaAdText.text != "" || hastaTCNOtext.text != "" || hastalikLabel.text != "" || ilaclarText.text != "" || ekNotText.text != "" {
            
            let databaseReference = Database.database().reference()
            let hastaKlasor = databaseReference.child("Hastalar/")
            let kayit = ["Hasta Ad" : hastaAdText.text!, "Hastalığı" : hastalikLabel.text!, "Doktor": doktor!,"Hasta TCNO" : hastaTCNOtext.text!, "İlaçlar": ilaclarText.text!, "Eknot" : ekNotText.text!, "Tarih" : tarihLabel.text!]
            hastaKlasor.child(hastaTCNOtext.text!).setValue(kayit)
            hastaAdText.text = ""
            hastalikLabel.text = ""
            hastaTCNOtext.text = ""
            ilaclarText.text = ""
            ekNotText.text = ""
        } else {
            let uyari = UIAlertController(title: "Hata", message: "Lütfen boş değer girmeyiniz...", preferredStyle: UIAlertController.Style.alert)
            let buton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.destructive, handler: nil)
            uyari.addAction(buton)
            self.present(uyari,animated: true,completion: nil)
        }
    }
    
    @IBAction func logOutClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Çıkış İşlemi", message: "Çıkış Yapmak İstediğinizden Emin misiniz ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hayır", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Evet", style: .destructive, handler: { action in
            switch action.style{
            case .destructive:
                // UserDefaults'taki "user" adındaki verimizi siliyoruz
                UserDefaults.standard.removeObject(forKey: "user")
                // UserDefaults'umuzu senkroniz ediyoruz
                UserDefaults.standard.synchronize()
                // Giriş ekranımızı tanımlıyoruz
                let signIn = self.storyboard?.instantiateViewController(withIdentifier: "signScreen") as! LogInVC
                // AppDelegate'imizi tanımlıyoruz
                let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                // Kullanıcıyı giriş ekranına yönlendiriyoruz
                delegate.window?.rootViewController = signIn
                // Tanımladığımız "delegate" değişkeni ile AppDelegate'in içindeki fonksiyonumuza ulaşıyoruz
                delegate.rememberUser()
                /* Do Try Catch bloğu ile kullanıcımızın Firebase'den çıkış yaptığımızı Firebase'e iletiyoruz
                 Bunu Do Try Catch ile yapmamızın sebebi hata olabilecek bir komut olmasıdır yani kullanıcı telefondan
                 çıkış yapsa bile Firebase'den çıkış yapamayabilir */
                do {
                    try Auth.auth().signOut()
                } catch {
                    print(error)
                }
            case .cancel:
                print("İşlem İptal Edildi")
            default:
                print("error")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        //dateformatter'ımızı tanımlıyoruz
        let dateFormatter = DateFormatter()
        //dateformatter'ımızın tarih saat şeklini ayarlıyoruz
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.timeStyle = DateFormatter.Style.short
        //seçilen tarihi string'e çeviriyoruz ve from ile kaynağın datepicker'daki seçilen tarih
        //olduğunu belirtiyoruz
        let strDate = dateFormatter.string(from: datePicker.date)
        //gizli label'ımıza string'i aktarıyoruz.Her tarih değiştiğinde bu label'daki text'de değişecek
        tarihLabel.text = strDate
    }
    

}

extension DataVC: UIPickerViewDelegate,UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //pickerView'da ne kadar veri varsa o kadar veri döndürmesini sağlıyoruz
        return dataSource.count
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //gizli labeldan hastalık alacağımız için seçilen veriyi label'a aktarıyoruz.
        hastalikLabel.text = dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
}
