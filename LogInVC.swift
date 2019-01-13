//
//  ViewController.swift
//  hastaneproje
//
//  Created by Caner Altuner on 2.12.2018.
//  Copyright © 2018 Caner Altuner. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LogInVC: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
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

    @IBAction func logInPressed(_ sender: Any) {
        if emailText.text != "" && passwordText.text != "" {
            //Eğer textfield'lar boş değilse kullanıcımızın giriş yapmasını sağlıyoruz
            /* Kullanıcımızı kendimiz Firebase'den oluşturacağımız için sadece giriş kısmını yapıyoruz
             "email" ve "password" kısmına emailtext ve passwordtext'lerimizi tanımladık.Çünkü bu veriler üzerinde
             Firebase öyle bir kullanıcı var mı yok mu diye kontrol edecek */
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (userdata, error) in
                if error != nil { //Eğer hatamız boş değilse yani hata varsa kullanıcıya bunu bildiriyoruz
                    // Uyarı penceremizi tanımlıyoruz
                    let uyari = UIAlertController(title: "Hata", message: "Lütfen kullanıcı adınızı ve şifrenizi doğru giriniz", preferredStyle: UIAlertController.Style.alert)
                    // Penceremizin butonunu tanımlıyoruz
                    let buton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
                    // Butonumuzu uyarı penceremize ekliyoruz
                    uyari.addAction(buton)
                } else {
                    // Hata yoksa kullanıcımızın giriş yapmasını sağlıyor ve onun bilgilerini cihaza kaydediyoruz
                    // Kullanıcının bilgilerini "user" adında kelimeye kaydediyoruz
                    UserDefaults.standard.set(userdata!.user.email, forKey: "user")
                    // Daha sonra bilgilerimizi "synchronize" komutu ile senkronize ediyoruz
                    UserDefaults.standard.synchronize()
                    // AppDelegate'e yani Programın temeline ulaşmak için AppDelegate'i tanımlıyoruz
                    let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    // AppDelegate'i tanımladığımız değişken üzerinden AppDelegate fonksiyonumuza ulaşıyoruz
                    delegate.rememberUser()
                }
            }
        } else {
            // Eğer bu emailtext veya passwordtext boşsa kullanıcımıza uyarı gösteriyoruz
            let uyari = UIAlertController(title: "Hata", message: "Lütfen boş kutucuk bırakmayın", preferredStyle: UIAlertController.Style.alert)
            let buton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
            uyari.addAction(buton)
        }
    }
}
//burada extension yapmamın sebebi diğer view'lardan da bu fonksiyonuma erişmek
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        //tap adında dokunma objesi tanımlıyorum,hedefini çalıştığı view,action yapacağı işi ise dismissKeyboard adında bir fonksiyonda tanımlıyorum
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false //dokunmanın view içinde iptal olmaması için false yapıyoruz
        view.addGestureRecognizer(tap) //view'a tap adındaki dokunma objemizi ekliyoruz
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) //endEditing'i true yapıyoruz ki klavye aşağı insin
    }
}
