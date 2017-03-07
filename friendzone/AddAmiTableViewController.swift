//
//  AddAmiTableViewController.swift
//  friendzone
//
//  Created by Julien on 06/03/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit

class AddAmiTableViewController: UITableViewController, DataBaseDelegateTableAmis {

    var data = DataBaseTableAmis()
    var config = Config()
    var connect_id = ""
    
    func dataLoaded()
    {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let name = self.config.defaults.string(forKey: "name")
        {
            connect_id = name
        }
        
        data.delegate = self
        data.loadData(TableView: self, Type: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.list.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblView", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = data.list[indexPath.row].nom
        cell.detailTextLabel?.text = data.list[indexPath.row].nb
        cell.imageView?.image = data.list[ indexPath.row].img
        
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nom = data.list[indexPath.row].nom
        let nb = data.list[indexPath.row].id
        
        
        let url = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&action=add_friend&values[id_amis]=\(nb)&values[id_co]=\(connect_id)"
        
        data.alertPrintRet(TitleController: "Ajouter \(nom) en ami ?",MsgController: "Ajouter en ami ?", Url: url , TableView: self)
        
        self.viewDidLoad()
        
    }

}
