//
//  DesignBarViewController.swift
//  friendzone
//
//  Created by Julien Xu on 13/03/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit

class DesignBarViewController: UINavigationController, UINavigationBarDelegate {

    @IBOutlet weak var navigationBarHeader: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarHeader.delegate = self
        
        //Navigation bar invisible
        navigationBarHeader.setBackgroundImage(UIImage(), for: .default)
        navigationBarHeader.shadowImage = UIImage()
        navigationBarHeader.isTranslucent = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = navigationBarHeader.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationBarHeader.insertSubview(blurEffectView, at: 0)
        
        
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
