//
//  ViewController.swift
//  shoppingList
//
//  Created by Alejandro Gonzalez on 9/5/21.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getData()
        refreshControl.endRefreshing()
    }
    
    func getData() {
        var new_data = [String]()
        var new_keys_data = [String:String]()
        db.collection("Items").getDocuments() { [weak tableView] (querySnapshot, err) in
            print("getting data")
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    new_data.append(document.data()["Item"] as! String)
                    new_keys_data[document.data()["Item"] as! String] = document.documentID
                }
                self.data_keys = new_keys_data
                self.data = new_data
                if self.data == [] {
                    self.data = ["add an item."]
                }
                tableView?.reloadData()
            }
        }
    }
    
    func addData(_ item: String) {
        db.collection("Items").addDocument(data: ["Item": item])
        getData()
    }
    
    func removeData(_ item: String) {
        if data != ["add an item."] {
            db.collection("Items").document(data_keys[item]!).delete()
            getData()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count > 0 {
            return data.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = data[indexPath.row]
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        print(selectedItem)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeData(data[indexPath.row])
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
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
