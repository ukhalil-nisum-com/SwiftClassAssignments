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
    var fetchedResultsController: NSFetchedResultsController<EntityBase>!
    let backgroundDataCoordinator:BackgroundDataCoordinator = BackgroundDataCoordinator()
    
    let searchController = UISearchController(searchResultsController: nil)
    let allScope = "All"
    
    @IBOutlet weak var refreshHandler: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeFetchedResultsController()
//        navigationController!.navigationBar.topItem?.title = "Item Search"
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelHandler(sender:)))
        self.loadTableData()
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = [allScope, String(describing: EntityType.Item), String(describing: EntityType.Bin), String(describing: EntityType.Location)]
        tableView.tableHeaderView = searchController.searchBar
        tableView.accessibilityLabel = "Search Table"
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
        backgroundDataCoordinator.requestAndLoadEntities(entityType: EntityType.Item, completionHandler: nil)
        backgroundDataCoordinator.requestAndLoadEntities(entityType: EntityType.Bin, completionHandler: nil)
        backgroundDataCoordinator.requestAndLoadEntities(entityType: EntityType.Location, completionHandler: nil)
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
        let entity = self.fetchedResultsController?.object(at: indexPath)
        cell.textLabel?.text = "\(entity?.entityTypeValue ?? "<none>"): \((entity?.name!)!)"
        if let item = entity as? Item    {
            cell.detailTextLabel?.text = "Bin: \(item.itemToBinFK?.name ?? "<none>"), Location: \(item.itemToBinFK?.binToLocationFK?.name ?? "<none>")"
        }
        if let bin = entity as? Bin    {
            cell.detailTextLabel?.text = "Location: \(bin.binToLocationFK?.name ?? "<none>")"
        }
        if let location = entity as? Location    {
            cell.detailTextLabel?.text = "Location: \(location.name!)"
        }
        cell.accessibilityLabel = "Cell: \(entity?.id)"
        cell.contentView.accessibilityLabel = "Content: \(entity?.id)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.entity = self.fetchedResultsController?.object(at: indexPath)
        print("\(self.entity?.name!) selected")
        self.performSegue(withIdentifier: "unwindToAddItem", sender: self)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String) {
        var predicate:NSPredicate? = nil
        if searchText.isEmpty {
            if scope != allScope {
                predicate = NSPredicate(format: "entityTypeValue == %@", scope)
            }
        } else {
            if scope != allScope {
                predicate = NSPredicate(format: "name CONTAINS[cd] %@ and entityTypeValue == %@", searchText, scope)
            } else {
                predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            }
        }
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetched results fetch has failed")
        }
        tableView.reloadData()
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
