//
//  ConnexionViewController.swift
//  friendzone
//
//  Created by Julien on 06/03/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit
import Foundation

class ConnexionViewController: UIViewController {

    var config = Config()
    
    @IBOutlet weak var password_input: UITextField!
    @IBOutlet weak var pseudo_input: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var login_session:String = ""
    var success = false
    var connect_id = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = self.config.defaults.string(forKey: "name")
        {
            connect_id = name
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        
        view.addGestureRecognizer(tap)
        
        
        //pseudo_input.text = "try@me.com"
        //password_input.text = "test"
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
                print("lol?")
            }
            else if(success){
                print("miaou")
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
                    
                    
                }
                catch{
                    
                    let nsError = error as NSError
                    print(nsError.localizedDescription)
                    
                }
                
                }.resume()
        }
        
        return self.success
        
    }
    
    
}
