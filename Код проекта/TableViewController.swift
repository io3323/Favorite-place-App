//
//  TableViewController.swift
//  ScrolView
//
//  Created by Игорь Островский on 03.05.2022.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController{
   
    @IBOutlet var  reversedSortedButton:UIBarButtonItem!
    
    private var searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searcBarIsEmpty : Bool{
        guard let text =  searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering:Bool{
        return searchController.isActive && !searcBarIsEmpty
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
        
        //Настройка SeachController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
      
        return 1
    }*/

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
       return places.isEmpty ? 0 : places.count
    
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        if isFiltering{
            
            place = filteredPlaces[indexPath.row]
        }else{
            place = places[indexPath.row]
        }
        
        
        cell.locationLabel.text = place.location
        cell.typelabel.text = place.type
        cell.nameLabel.text = place.name
        //cell.nameLabel.numberOfLines = 0
        cell.imageView?.layer.cornerRadius = cell.frame.size.height/2
        cell.imageView?.clipsToBounds = true
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
      
        return cell
    }
    // MARK: - Table view deleagate(Позволит вызывать различные пункты менб при свайпе ячейки с права на лево)
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return[deleteAction]
    }
    // MARK: - Table view delegate (Данный метод возвращает высоту строки)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let place: Place
            if isFiltering{
                place = filteredPlaces[indexPath.row]
            }else{
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! SecondTableViewController
            newPlaceVC.currentPlace = place
        }
    }
    // MARK: - Данный метод используется для возможности создания обратного перехода на главную страницу
    @IBAction func unwindSegue(segue:UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? SecondTableViewController else {return}
        
        newPlaceVC.savePlace()
        
  
        tableView.reloadData()
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    


    
    @IBAction func reversedSorting(_ sender:Any){
      

}
}
extension TableViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    private func filterContentForSearchText(_ searchText:String){
       
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText,searchText)
        
        tableView.reloadData()
    }
}
