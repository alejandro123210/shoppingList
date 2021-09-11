//
//  ViewController.swift
//  shoppingList
//
//  Created by Alejandro Gonzalez on 9/5/21.
//

import UIKit
import FirebaseFirestore


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var db : Firestore!
    var data: [String] = ["add an item."]
    var data_keys: [String:String] = [:]
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if data == [] {
            data = ["add an item."]
        }
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ViewCell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        getData()
    }
    
    //pull down to refresh
    @objc func refresh(_ sender: AnyObject) {
        getData()
        refreshControl.endRefreshing()
    }
    
    //get the data from the DB
    func getData() {
        var new_data = [String]()
        var new_keys_data = [String:String]()
        db.collection("Items").getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    new_data.append(document.data()["Item"] as! String)
                    new_keys_data[document.data()["Item"] as! String] = document.documentID
                }
                self?.data_keys = new_keys_data
                self?.data = new_data
                if self?.data == [] {
                    self?.data = ["add an item."]
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    
    //add new element to DB
    func addData(_ item: String) {
        db.collection("Items").addDocument(data: ["Item": item])
        getData()
    }
    
    //delete element from DB
    func removeData(_ index: Int) {
        if data != ["add an item."] {
            db.collection("Items").document(data_keys[data[index]]!).delete()
            getData()
        }
    }
    
    //sets length of tableview's list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count > 0 {
            return data.count
        } else {
            return 1
        }
    }
    
    //sets the cell to use for each index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    //sets an editing style so that the user can delete elements in the list
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeData(indexPath.row)
        }
    }
    
    //sets editing to true
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    //add button function, let's user type in name of item
    @IBAction func addButton(_ sender: Any) {
        print(data)
        showInputDialog(title: "Add item", subtitle: "",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Seltzer..",
                        inputKeyboardType: .default,
                        actionHandler: { (input:String?) in
            if input != "" && input != nil {
                self.addData(input!)
            }
        })
    }
    

}

//This extension basically creates an alert with a textbox, used in the add button so that we can add items
//to our shopping list
extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}
