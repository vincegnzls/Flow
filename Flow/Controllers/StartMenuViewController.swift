//
//  StartMenuViewController.swift
//  Flow
//
//  Created by Kevin Chan on 10/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class StartMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMenuShadow()
        self.setupTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupMenuShadow() {
        if self.menu != nil {
            self.menu.layer.shadowColor = UIColor.black.cgColor
            self.menu.layer.shadowOpacity = 0.1
            self.menu.layer.shadowOffset = CGSize.zero
            self.menu.layer.shadowRadius = 5
            self.menu.layer.shadowPath = UIBezierPath(rect: self.menu.bounds).cgPath
        }
    }
    
    private func setupTable() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

}
