//
//  ConnexionViewController.swift
//  friendzone
//
//  Created by Julien on 06/03/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit
import Foundation

class ConnexionViewController: UIViewController, UITextFieldDelegate {

    var config = Config()
    
    @IBOutlet weak var password_input: UITextField!
    @IBOutlet weak var pseudo_input: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    var login_session:String = ""
    var success = false
    var connect_id = ""
    
    
    override func viewDidLoad() {
        
        //Si l'utilisateur est connecté alors on le redirige vers l'activity map
        if(config.defaults.dictionaryRepresentation().keys.count != 0){
            if (self.config.defaults.string(forKey: "name") != nil)
            {
                //Redirection
                DispatchQueue.main.async {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainStoryboard_ID") as UIViewController
                    self.present(nextViewController, animated:true, completion:nil)
                }
                
            }
            else{
                print("NO RIEN DE RIEN")
            }

        }
        else{
        
        }
        
        

        super.viewDidLoad()
        
        //Flou
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.9
        blurEffectView.frame = backgroundImage.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImage.addSubview(blurEffectView)
        
        //Deisgn textfield
        bottomBorder(textField: pseudo_input)
        bottomBorder(textField: password_input)
        
        //Enlever le clavier
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let clavier = UIToolbar(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30)))
        clavier.barStyle = UIBarStyle.default
        
        clavier.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: self, action: "dismissKeyboard")
        ]
        clavier.sizeToFit()
        pseudo_input.inputAccessoryView = clavier
        password_input.inputAccessoryView = clavier
        
        view.addGestureRecognizer(tap)
    }
    
    func bottomBorder(textField : UITextField)
    {
        //Deisgn textfield
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.cyan.cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height:textField.frame.height)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func connexionClick(_ sender: Any) {
        let pseudo : String = pseudo_input.text!
        let password : String = password_input.text!
        
        if config.isInternetAvailable()
        {
            loadData(Pseudo: pseudo, Password: password)
            
            if(pseudo.isEmpty || password.isEmpty){
                success = false
                print("empty?")
            }
            else if(success){
                print("Id de la personne co : \(connect_id)")
            }
        }
        else
        {
            print("NO CONNECTION")
        }
    }

    public func loadData(Pseudo : String, Password : String) ->Bool
    {
        
        let urlApi = "\(config.url)action=connexion_ios&values[pseudo]=\(Pseudo)&values[mdp]=\(Password)"
        print(urlApi)
        if let url =  URL(string: urlApi){
            URLSession.shared.dataTask(with: url){
                (myData, response, error) in
                //guard inverse de if
                guard let myData = myData, error == nil else{
                    //Pas de data ou error
                    print("error")
                    return
                }
                
                do{
                    let root = try JSONSerialization.jsonObject(with: myData, options: .allowFragments)
                    if let json = root as? [[String: AnyObject]]{
                        for item in json{
                            for value in item{
                                let id_user = value.value as! String
                                print(id_user)
                                if(id_user != ""){
                                    
                                    self.config.defaults.set(id_user, forKey: "name")
                                    
                                    if let name = self.config.defaults.string(forKey: "name")
                                    {
                                        print(name)
                                    }
                                    
                                    self.connect_id = id_user
                                    self.success = true
                                    
                                    //Redirection
                                    DispatchQueue.main.async {
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        
                                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainStoryboard_ID") as UIViewController
                                        self.present(nextViewController, animated:true, completion:nil)
                                    }
                                    
                                }
                                else{
                                    self.success = false
                                }
                            }
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.alertPrint(TitleController: "Erreur", MsgController: "Identifiant ou mot de passe incorrect", Titlealt: "Fermer")
                        }
                    }
                    
                    
                }
                catch{
                    
                    let nsError = error as NSError
                    print(nsError.localizedDescription)
                    
                }
                
                }.resume()
        }
        
        return self.success
        
    }
    
    func alertPrint(TitleController: String,MsgController: String, Titlealt: String) -> Void {
        let alert = UIAlertController(title: TitleController, message: MsgController,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Titlealt, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
