//
//  TableViewController.swift
//  TableView
//
//  Created by Саша Гужавин on 01.10.2020.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var places: Results<Place>!
    private var filtredPlaces: Results<Place>!
    private let searchController = UISearchController(searchResultsController: nil)
    private var ascendingSorting = true
    private var searchBarIsEmty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFilterin: Bool {
        return searchController.isActive && !searchBarIsEmty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmenedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        
        // Настройка SearchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilterin {
            return filtredPlaces.count
        } else{
            return places.isEmpty ? 0 : places.count
        }
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

        var place = Place()
        
        if isFilterin {
            place = filtredPlaces[indexPath.row ]
        } else {
            place = places[indexPath.row]
        }

        cell.nameLable.text = place.name
        cell.locationLable.text = place.location
        cell.typeLable.text = place.type
        cell.imagaOfPlace.image = UIImage(data: place.imageData!)
        cell.imagaOfPlace.layer.cornerRadius = cell.imagaOfPlace.frame.size.height / 5
        cell.imagaOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: - Table view delegate
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_,_) in
            
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDelail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            var place = Place()
            
            if isFilterin {
                place = filtredPlaces[indexPath.row ]
            } else {
                place = places[indexPath.row]
            }
            
            let newPlaceVC = segue.destination as! AddNewPlace
            newPlaceVC.currentPlace = place
        }
    }
    
    // MARK: - IBAction
    
    @ IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? AddNewPlace else {return}
        
        newPlaceVC.savePlace()
        tableView.reloadData()
        
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
        sorting()
    }
    @IBAction func revercedSorting(_ sender: Any) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "reverseDOWN")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "reverseUP")
        }
        sorting()
    }
    
    private func sorting() {
        
        if segmenedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    private func filterContentForSearchText(_ searchText: String) {
        
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
