//
//  CloudkitManager.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/31/20.
//

import Foundation
import CloudKit

class CloudKitManager: ObservableObject {
    
    private let container = CKContainer.default()
    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    var userId: CKRecord.ID?
    var userRecord: CKRecord?
    var fullname: String = ""
    var userBio: String {
        guard let record = userRecord else { return ""}
        
        return record["bio"] as? String ?? "wtf"
    }
    
    init() {
        getAccountStatus()
        }
    
    func getAccountStatus() {
        container.accountStatus { (status, error) in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    print("error occured")
                } else {
                    self?.accountStatus = status
                    switch status {
                    case .available:
                      // the user is logged in
                        print("User is logged in")
                        self?.getUserId()
                        return
                    case .noAccount:
                      // the user is NOT logged in
                        print("user not logged in")
                        return
                    case .couldNotDetermine:
                      // for some reason, the status could not be determined (try again)
                        print("not sure what happened")
                        return
                    case .restricted:
                      // iCloud settings are restricted by parental controls or a configuration profile
                        print("access is restricted")
                        return
                    @unknown default:
                      // ...
                        print("unknown ting")
                        return
                    }
                }
            }
        }
    }
    
    //Set User Id on userId Property
    func getUserId() {
        container.fetchUserRecordID { (recordId, error) in
            DispatchQueue.main.async  { [weak self] in
                if let error = error {
                    print("error occured")
                } else {
                    guard let id = recordId else { return }

                    self?.userId = id
                }
            }
        }
    }
    
    //Set User Record on Property called userRecord
    func getUserRecord() {
        guard let id = self.userId else { return }
        
        container.publicCloudDatabase.fetch(withRecordID: id) { (record, error) in
            
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    
                } else {
                    guard let record = record else { return }
                    
                    self?.userRecord = record
                }
            }
        }
    }
    
    //Request Permission for user info
    func requestUserInfo() {
        
        DispatchQueue.main.async { [weak self] in
            self?.container.requestApplicationPermission(.userDiscoverability) { (status, error) in
                guard status == .granted, error == nil else {
                        // error handling voodoo
                        return
                    }
                
                guard let id = self?.userId else { return }
                
                DispatchQueue.main.async {
                  
                self?.container.discoverUserIdentity(withUserRecordID: id, completionHandler: { (identity, error) in
                    guard let components = identity?.nameComponents, error == nil else {
                            // more error handling magic
                            return
                        }
                    
                    let userFullName = PersonNameComponentsFormatter().string(from: components)
                    self?.fullname = userFullName
                    self?.getUserRecord()
                })
                
            }
            }
        }
    }
    
    //Update User Profile
    func updateUserProfile(userRecord: CKRecord) {
        DispatchQueue.main.async { [weak self] in
            self?.container.publicCloudDatabase.save(userRecord) { (_, error) in
                guard error == nil else {
                            // top-notch error handling
                            return
                    }
                
                print("Successfully updated")
            }
        }
        
    }
}
