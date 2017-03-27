//
//  InscriptionTableViewController.swift
//  friendzone
//
//  Created by root root on 02/03/2017.
//  Copyright © 2017 Friend Zone Corporation. All rights reserved.
//

import UIKit

class InscriptionTableViewController: UITableViewController {

    @IBOutlet var pseudo_input: UITextField!
    @IBOutlet var phone_input: UITextField!
    @IBOutlet var email_input: UITextField!
    @IBOutlet var password_input: UITextField!
    @IBOutlet var signinBtn: UIButton!
    
    @IBOutlet weak var navigationBarTitle: UINavigationBar!
    @IBOutlet var tableV: UITableView!
    
    var config = Config()
    
    var success = false
    var connect_id = ""
    
    @IBAction func retour_action(_ sender: Any)
    {
        //Redirection
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Connexion_ID") as UIViewController
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_sd"))
        tableView.alwaysBounceVertical = false;
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tableV.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableV.insertSubview(blurEffectView, at: 0)
        
        //Enlever le clavier
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let clavier = UIToolbar(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30)))
        clavier.barStyle = UIBarStyle.default
        view.addGestureRecognizer(tap)
        
        //Design textfield
        bottomBorder(textField: pseudo_input)
        bottomBorder(textField: password_input)
        bottomBorder(textField: email_input)
        bottomBorder(textField: phone_input)
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
    
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func signIn(_ sender: Any) {
        let pseudo : String = pseudo_input.text!
        let password : String = password_input.text!
        let email : String = email_input.text!
        let phone : String = phone_input.text!
        //Penser à faire le contrôle de saisis
        
        if(pseudo.isEmpty || password.isEmpty || email.isEmpty || phone.isEmpty){
            success = false
            print("lol? trop false")
        }
        
        loadData(Pseudo: pseudo, Password: password, Email: email, Phone: phone)
        
    }
    
    func loadData(Pseudo : String, Password : String, Email : String, Phone : String) ->Bool{
        if let name = self.config.defaults.string(forKey: "name")
        {
            connect_id = name
        }
        
        let urlApi = "\(config.url)action=inscription_ios&values[nom]=testnom&values[prenom]=testprenom&values[mdp]=\(Password)&values[tel]=\(Phone)&values[pseudo]=\(Pseudo)&values[mail]=\(Email)"
        if let url =  URL(string: urlApi){
            URLSession.shared.dataTask(with: url){(myData, response, error) in
                guard let myData = myData, error == nil else{
                    print("error")
                    return
                }
                do{
                    let root = try JSONSerialization.jsonObject(with: myData, options: .allowFragments)
                    if let json = root as? [String : AnyObject]{
                    
                        let error_code = json["error"] as! String
                        let id_user_inscrip = json["id"] as! String
                        self.connect_id = id_user_inscrip
						self.config.defaults.set(id_user_inscrip, forKey: "name")

                        print(error_code)
                        print(id_user_inscrip)
                        print(self.connect_id)
                        
                            
                        if(error_code == "ok"){
                            self.success = true
                            print("OK REDIRECTION")
							DispatchQueue.main.async {
								let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
								
								let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainStoryboard_ID") as UIViewController
								self.present(nextViewController, animated:true, completion:nil)
							}

                        }
                        else if(error_code == "error_mail"){
                            self.success = false
                            print("EMAIL EXISTANT")
                        }
                        else{
                            self.success = false
                            print("PSEUDO EXISTANT")
                        }
                    }
                }
                catch{
                    let errorCatched = error as NSError
                    print(errorCatched.localizedDescription)
                }
                }.resume()
        }
        
        
        return self.success
    }
    
}
