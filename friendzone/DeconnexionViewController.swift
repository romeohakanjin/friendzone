//
//  DeconnexionViewController.swift
//  friendzone
//
//  Created by Julien Xu on 13/03/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit

class DeconnexionViewController: UINavigationController {

    var config = Config()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        
        //Enleve une clé du dico
        config.defaults.removeObject(forKey: "name")
        print(config.defaults.dictionaryRepresentation().keys.count)

        //Redirection
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Connexion_ID") as UIViewController
            self.present(nextViewController, animated:true, completion:nil)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
