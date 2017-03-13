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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_sd"))
        tableView.alwaysBounceVertical = false;
        
        //Navigation bar invisible
        navigationBarTitle.setBackgroundImage(UIImage(), for: .default)
        navigationBarTitle.shadowImage = UIImage()
        navigationBarTitle.isTranslucent = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tableV.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableV.insertSubview(blurEffectView, at: 0)
        
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
