//
//  StartMenuViewController.swift
//  Flow
//
//  Created by Kevin Chan on 10/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class StartMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Constants
    private let cellIdentifier = "CompositionTableViewCell"

    // MARK: Outlets
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Properties
    private var compositions = [CompositionInfo]()
    private var compIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMenuShadow()
        self.setupTable()

        for i in 1..<5 {
            self.compositions.append(CompositionInfo(name: "Composition \(i)"))
            //self.compositions.append(CompositionInfo(name:"Composition 2"))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup methods
    
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

        //self.tableView.register(CompositionTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        //self.tableView.separatorStyle = .none
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.compositions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? CompositionTableViewCell else {
            fatalError("The dequeued cell is not an instance of " + self.cellIdentifier)
        }

        let composition = self.compositions[indexPath.row]
        cell.nameLabel.text = composition.name
        cell.lastEditedLabel.text = composition.lastEditedString

        /*print ("I'm here")
        if self.compIndex < self.compositions.count {
            let composition = compositions[compIndex]
            cell.view1.nameLabel.text = composition.name
            cell.view1.lastEditedLabel.text = composition.lastEditedString

            self.compIndex += 1

            if self.compIndex < self.compositions.count {
                let composition = compositions[self.compIndex]
                cell.view2.nameLabel.text = composition.name
                cell.view2.lastEditedLabel.text = composition.lastEditedString
            }

            self.compIndex += 1

            if self.compIndex < self.compositions.count {
                let composition = compositions[self.compIndex]
                cell.view3.nameLabel.text = composition.name
                cell.view3.lastEditedLabel.text = composition.lastEditedString
            }
        } else {
            cell.isHidden = true
            if indexPath.row == self.compositions.count - 1 {
                self.compIndex = 0
            }
        }*/

        /*let index = compIndex
        let composition = compositions[index]
        cell.view1.nameLabel.text = composition.name
        cell.view1.lastEditedLabel.text = composition.lastEditedString

        cell.view2.nameLabel.text = composition.name + " test"
        cell.view3.nameLabel.text = "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog."
        //cell.column1.text = "1" // fill in your value for column 1 (e.g. from an array)
        //cell.column2.text = "2" // fill in your value for column 2*/
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    */
}
