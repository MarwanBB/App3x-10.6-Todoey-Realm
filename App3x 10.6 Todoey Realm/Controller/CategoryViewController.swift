//
//  ViewController.swift
//  App3x 10.1 Todoey
//
//  Created by Marwan Elbahnasawy on 04/06/2022.
//

import UIKit
import RealmSwift
import SwipeCellKit
import CyaneaOctopus
import UIColor_Hex_Swift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var categoryEntity : Results<Category>!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font : UIFont(name: "Marker Felt", size: 40)]
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        searchBar.barTintColor = .systemBlue
        searchBar.searchTextField.backgroundColor = .white
        
    }

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Todoey", message: "Add a new category", preferredStyle: .alert)
        var alertTextField = UITextField()
        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
            if alertTextField.text == "" { }
            else if let safeAlertTextFieldText = alertTextField.text {
                
                let newCategory = Category()
                newCategory.titleCategory = safeAlertTextFieldText
                newCategory.dateCategory = Date()
                newCategory.colorCategory = UIColor.randomFlatColor()?.hexString()
                
                self.saveCategories(category: newCategory)
            }
            
        }
        alert.addAction(alertAction)
        alert.addTextField { textField in
            textField.placeholder = "Category Title"
            alertTextField = textField
        }
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryEntity.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categoryEntity[indexPath.row].titleCategory
        cell.backgroundColor = UIColor("\(categoryEntity[indexPath.row].colorCategory!)")
        cell.textLabel?.textColor = UIColor.contrastColor(UIColor("\(categoryEntity[indexPath.row].colorCategory!)"), true)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueID", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemViewController
        let indexPath = tableView.indexPathForSelectedRow
        destinationVC.selectedCategory = categoryEntity[indexPath!.row]
    }
    
    func loadCategories(){
        
        categoryEntity = realm.objects(Category.self).sorted(byKeyPath: "dateCategory", ascending: false)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }


    }
    
    func saveCategories(category: Category){
        try! realm.write {
            realm.add(category)
        }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }


    }
    
}
    

extension CategoryViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            loadCategories()
        }
        else {
            categoryEntity = realm.objects(Category.self).sorted(byKeyPath: "dateCategory", ascending: false).filter("titleCategory CONTAINS [cd] %@", searchBar.text)
    }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
}
}

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [self] action, indexPath in
            // handle action by updating model with deletion
            try! realm.write {
                realm.delete(categoryEntity[indexPath.row])
            }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
