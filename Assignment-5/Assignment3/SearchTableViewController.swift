//
//  SearchTableViewController.swift
//  Assignment3
//
//  Created by NISUM on 6/19/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import UIKit
import CoreData

class SearchTableViewController: UITableViewController, NameProtocol {
    

    var entity:EntityBase?
    private var filteredEntityArray = [EntityBase]()
    var fetchedResultsController: NSFetchedResultsController<Item>!
    let backgroundDataCoordinator:BackgroundDataCoordinator = BackgroundDataCoordinator()
    
    let searchController = UISearchController(searchResultsController: nil)
    let allScope = "All"
    var currentScope:String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var refreshHandler: UIRefreshControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeFetchedResultsController()
        self.title = "Item Search"
    //    navigationController!.navigationBar.topItem?.title = "Item Search"
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
    
    func initializeFetchedResultsController() {
        let coreDataFetch:CoreDataFetch = CoreDataFetch()
        fetchedResultsController = coreDataFetch.getFetchedResultsController()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func loadTableData()    {
        backgroundDataCoordinator.requestAndLoadEntities(objectType: "Item")
        //        do {
        //            let fetchUtility = FetchUtility()
        ////            entityArray = fetchUtility.fetchSortedLocation()!
        //        } catch {
        //            print("Fetch error \(error.localizedDescription)")
        //        }
        //        filteredEntityArray = entityArray
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)
        let item = self.fetchedResultsController?.object(at: indexPath)
        cell.textLabel?.text = "\(item?.entityTypeValue ?? "<none>"): \((item?.name!)!)"
        cell.detailTextLabel?.text = "Bin: \(item?.itemToBinFK?.name ?? "<none>"), Location: \(item?.itemToBinFK?.binToLocationFK?.name ?? "<none>")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.entity = filteredEntityArray[indexPath.row]
        print("\(self.entity?.name!) selected")
        self.performSegue(withIdentifier: "unwindToAddItem", sender: self)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String) {
        //        filteredEntityArray = entityArray.filter({[weak self] ( entity : EntityBase) -> Bool in
        //            self!.currentScope = scope
        //            let entityTypeMatch = (self!.currentScope == self!.allScope || String(describing:entity.entityType!) == scope)
        //            let name = entity.name!.lowercased()
        //            print("\(String(describing:entity.entityType!)) \(name) entityTypeMatch: \(entityTypeMatch) searchTextMatch: \(searchText == "" || entity.name!.lowercased().contains(searchText.lowercased()))")
        //            return entityTypeMatch && (searchText == "" || entity.name!.lowercased().contains(searchText.lowercased()))
        //        })
        //        tableView.reloadData()
    }
    
    @IBAction func refreshHandler(_ sender: UIRefreshControl) {
        loadTableData()
    }
    
    func cancelHandler(sender: UIBarButtonItem) {
        print("Cancel clicked!")
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension SearchTableViewController:NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        if self.refreshControl != nil && self.refreshControl!.isRefreshing   {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
