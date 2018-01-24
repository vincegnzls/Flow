//
//  StartMenuViewController.swift
//  Flow
//
//  Created by Kevin Chan on 10/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class StartMenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: Constants
    private let cellIdentifier = "CompositionCell"

    // MARK: Outlets
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        //self.tableView.register(CompositionTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        //self.tableView.separatorStyle = .none
    }
    
    // MARK: Table view data source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.compositions.count
    }

    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // get a reference to our storyboard cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath as IndexPath) as?
            CompositionCollectionViewCell else {
                fatalError("The dequeued cell is not an instance of \(self.cellIdentifier)")
             }

        let composition = self.compositions[indexPath.row]
        cell.nameLabel.text = composition.name
        cell.lastEditedLabel.text = composition.lastEditedString
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        //cell.myLabel.text = self.items[indexPath.item]
        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project

        return cell
    }

    // MARK: - UICollectionViewDelegate protocol

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
}
