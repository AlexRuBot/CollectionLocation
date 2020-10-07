//
//  TableViewController.swift
//  TableView
//
//  Created by Саша Гужавин on 01.10.2020.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {
    
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

        let place = places[indexPath.row]

        cell.nameLable.text = place.name
        cell.locationLable.text = place.location
        cell.typeLable.text = place.type
        cell.imagaOfPlace.image = UIImage(data: place.imageData!)
        cell.imagaOfPlace.layer.cornerRadius = cell.imagaOfPlace.frame.size.height / 5
        cell.imagaOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
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
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! AddNewPlace
            newPlaceVC.currentPlace = place
        }
    }
    
    // MARK: - Segue
    
    @ IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? AddNewPlace else {return}
        
        newPlaceVC.savePlace()
        tableView.reloadData()
        
    }
    

}
