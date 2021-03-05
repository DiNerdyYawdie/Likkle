//
//  SearchHomeViewModel.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import Foundation
import Combine
import CloudKit

class SearchHomeViewModel: ObservableObject {
    
    @Published var serialNumber: String  = ""
    @Published var showAddPostModal: Bool = false
    @Published var showAlert: Bool = false
    @Published var showProfileModal: Bool = false
    @Published var posts: [CD_Post] = []
    
    //MARK: Get Posts
    func getPosts() {
        self.posts.removeAll()
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_Post", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { post in
            let id = post.object(forKey: "CD_userId") as? String ?? "N/A"
            let postSerialNumber = post.object(forKey: "CD_serialNumber") as? String ?? "N/A"
            let postCaption = post.object(forKey: "CD_caption") as? String ?? "N/A"
            DispatchQueue.main.async { [weak self] in
                self?.posts.append(CD_Post(CD_userId: id, CD_serialNumber: postSerialNumber, CD_caption: postCaption))
            }
            
        }
        
        operation.queryCompletionBlock = { cursor, error in
            // recipeRecords now contains all records fetched during the lifetime of the operation
            print(self.posts.count)
        }
        
        
        
        var subscription = CKQuerySubscription(recordType: "CD_Post", predicate: predicate, options: .firesOnRecordCreation)
        CKContainer.default().publicCloudDatabase.save(subscription) { (recordSub, error) in
            if let error = error {
                return
            }
        }
        
        operation.qualityOfService = .userInitiated
        CKContainer.default().publicCloudDatabase.add(operation)
        
    }
}
