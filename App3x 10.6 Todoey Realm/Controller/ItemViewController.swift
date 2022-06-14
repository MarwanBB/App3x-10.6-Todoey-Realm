//
//  ItemViewController.swift
//  App3x 10.5 Todoey CoreData + Other Controller
//
//  Created by Marwan Elbahnasawy on 04/06/2022.
//

import UIKit
import RealmSwift
import SwipeCellKit
import CyaneaOctopus
import UIColor_Hex_Swift

class ItemViewController: UITableViewController {
    let realm = try! Realm()
    
    var selectedCategory: Category! {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemEntity : Results<Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor("\(selectedCategory.colorCategory!)")
        
        navigationController?.navigationBar.tintColor = UIColor.contrastColor(appearance.backgroundColor!, true)
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        searchBar.barTintColor = UIColor("\(selectedCategory.colorCategory!)")
        searchBar.searchTextField.backgroundColor = .white
    }

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Todoey", message: "Add a new memo", preferredStyle: .alert)
        var alertTextField = UITextField()
        let alertAction = UIAlertAction(title: "Add", style: .default) { action in
            if alertTextField.text == "" { }
            else if let safeAlertTextFieldText = alertTextField.text {
                
                let newItem = Item()
                newItem.titleItem = safeAlertTextFieldText
                newItem.doneItem = false
                newItem.dateItem = Date()
                newItem.colorItem = self.selectedCategory.colorCategory
                
                self.saveItems(item: newItem)
            }
            
        }
        alert.addAction(alertAction)
        alert.addTextField { textField in
            textField.placeholder = "Memo Title"
            alertTextField = textField
        }
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemEntity.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        cell.textLabel?.text = itemEntity[indexPath.row].titleItem
        cell.accessoryType = itemEntity[indexPath.row].doneItem == true ? .checkmark : .none
        cell.backgroundColor = UIColor("\(itemEntity[indexPath.row].colorItem!)").darken(by: CGFloat((indexPath.row)*100/selectedCategory.items.count) )
        cell.textLabel?.textColor = UIColor.contrastColor(cell.backgroundColor!, true)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemEntity[indexPath.row].doneItem = !itemEntity[indexPath.row].doneItem
        saveItems(item: itemEntity[indexPath.row])
    }
    
    func loadItems(){
        
        itemEntity = selectedCategory.items.sorted(byKeyPath: "dateItem", ascending: false)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }


    }
    
func saveItems(item: Item){
        try! realm.write {
            selectedCategory.items.append(item)
        }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }


    }
    
}

extension ItemViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text == "" {
            loadItems()
        }
        else {
            itemEntity = selectedCategory.items.sorted(byKeyPath: "dateItem", ascending: false).filter("titleItem CONTAINS [cd] %@", searchBar.text)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
}

extension ItemViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") {[self] action, indexPath in
            // handle action by updating model with deletion
            try! realm.write {
                realm.delete(itemEntity[indexPath.row])
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
