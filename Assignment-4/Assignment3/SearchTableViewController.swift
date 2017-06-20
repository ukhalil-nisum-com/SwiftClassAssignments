//
//  SearchTableViewController.swift
//  Assignment3
//
//  Created by NISUM on 6/19/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import UIKit

class ItemSearchTableViewController: UITableViewController {
    
    var entity:EntityBase?
    private var entityArray = [EntityBase]()
    private var filteredEntityArray = [EntityBase]()
    let searchController = UISearchController(searchResultsController: nil)
    let allScope = "All"
    var currentScope:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.topItem?.title = "Item Search"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelHandler(sender:)))
        self.loadTableData()
        currentScope = allScope
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = [allScope, String(describing: EntityType.Item), String(describing: EntityType.Bin), String(describing: EntityType.Location)]
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func loadTableData()    {
        entityArray.append(Item(name: "Drill", qty:1, bin: Bin(name: "Top Shelf", location: Location(name: "Closet"))))
        entityArray.append(Item(name: "Screws", qty:12, bin: Bin(name: "Bottom Drawer", location: Location(name: "Basement"))))
        entityArray.append(Item(name: "Wood", bin: Bin(name: "Last Cabinet", location: Location(name: "Storage"))))
        entityArray.append((entityArray[0] as! Item).bin!)
        entityArray.append((entityArray[1] as! Item).bin!)
        entityArray.append((entityArray[2] as! Item).bin!)
        entityArray.append((entityArray[0] as! Item).bin!.location!)
        entityArray.append((entityArray[1] as! Item).bin!.location!)
        entityArray.append((entityArray[2] as! Item).bin!.location!)
        filteredEntityArray = entityArray
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntityArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)
        let entity:EntityBase? = filteredEntityArray[indexPath.row]
        cell.textLabel?.text = entity!.name!
        if let item = entity as? Item? {
            cell.detailTextLabel?.text = "Bin: \(item!.bin!.name!), Location: \(item!.bin!.location!.name!)"
        } else if let bin = entity as? Bin? {
            cell.detailTextLabel?.text = "Location: \(bin!.location!.name!)"
        }
        else if let location = entity as? Location? {
            cell.detailTextLabel?.text = "(\(String(describing: location!.entityType!)))"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.entity = filteredEntityArray[indexPath.row]
        print("\(String(describing: self.entity?.name!)) selected")
        self.performSegue(withIdentifier: "unwindToAddItem", sender: self)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String) {
        filteredEntityArray = entityArray.filter({[weak self] ( entity : EntityBase) -> Bool in
            self!.currentScope = scope
            let entityTypeMatch = (self!.currentScope == self!.allScope || String(describing:entity.entityType!) == scope)
            let name = entity.name!.lowercased()
            print("\(String(describing:entity.entityType!)) \(name) entityTypeMatch: \(entityTypeMatch) searchTextMatch: \(searchText == "" || entity.name!.lowercased().contains(searchText.lowercased()))")
            return entityTypeMatch && (searchText == "" || entity.name!.lowercased().contains(searchText.lowercased()))
        })
        tableView.reloadData()
    }
    
    func cancelHandler(sender: UIBarButtonItem) {
        print("Cancel clicked!")
        self.dismiss(animated: true, completion: nil)
    }
}

extension ItemSearchTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension ItemSearchTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}
