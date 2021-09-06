//
//  Backend.swift
//  shoppingList
//
//  Created by Alejandro Gonzalez on 9/5/21.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class Backend: NSObject {
    
    var db: Firestore!
    
    override init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func getData() -> [String] {
        let dispatchGroup = DispatchGroup()
        var data = [String]()
        dispatchGroup.enter()
        DispatchQueue.global(qos: .default).async {
            print("in the dispatche queue")
            self.db.collection("Items").getDocuments() { (querySnapshot, err) in
                print("getting data")
                if let err = err {
                    print("Error getting documents: \(err)")
                    data = ["error"]
                    dispatchGroup.leave()
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        data.append(document.data()["Item"] as! String)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.wait()
        return data
    }
}
