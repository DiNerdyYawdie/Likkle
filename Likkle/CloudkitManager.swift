//
//  CloudkitManager.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/31/20.
//

import Foundation
import CloudKit

struct CurrentUser {
    
    var fullName: String = ""
    var bio: String = ""
    var avatarURL: String = ""
    var userId: String = ""
}

class CloudKitManager: ObservableObject {
    
    private let container = CKContainer.default()
    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    var userId: CKRecord.ID?
    var userRecord: CKRecord?
    var currentUser: CurrentUser = CurrentUser()
    var fullname: String = ""
    
    //MARK: INIT() Get CloudKit Account Status
    init() { getAccountStatus() }
    
    //MARK: Get & Update Account Status for `self?.accountStatus`
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
                        print("unknown error occured")
                        return
                    }
                }
            }
        }
    }
    
    //MARK: Get & Set User FullName on `fullName` property
    func requestUserInfo() {
        DispatchQueue.main.async { [weak self] in
            self?.container.requestApplicationPermission(.userDiscoverability) { (status, error) in
                guard status == .granted, error == nil else { return }
                
                guard let id = self?.userId else { return }
                
                DispatchQueue.main.async {
                self?.container.discoverUserIdentity(withUserRecordID: id, completionHandler: { (identity, error) in
                    guard let components = identity?.nameComponents, error == nil else { return }
                    
                    let userFullName = PersonNameComponentsFormatter().string(from: components)
                    let updateNameRecord = CKRecord(recordType: "Users")
                    updateNameRecord["fullName"] = userFullName
                    self?.currentUser.fullName = userFullName
                    self?.saveRecord(record: updateNameRecord)
                })
            }
            }
        }
    }
    
    //MARK: Get & Set User Id on `userId` Property after status check
    func getUserId() {
        DispatchQueue.main.async  { [weak self] in
            self?.requestUserInfo()
            self?.container.fetchUserRecordID { (recordId, error) in
            
                if let error = error {
                    print("error occured")
                } else {
                    guard let id = recordId else { return }

                    self?.userId = id
                    self?.getUserRecord()
                }
            }
        }
    }
    
    //MARK: Use the current user's UserID to GET their User Record Info to make MODEL `CurrentUser`
    func getUserRecord() {
        guard let userId = self.userId else { return }
        DispatchQueue.main.async { [weak self] in
            self?.container.publicCloudDatabase.fetch(withRecordID: userId) { (record, error) in
            
                if let error = error {
                    
                } else {
                    guard let record = record else { return }
                    
                    let name = record.object(forKey: "fullName") as? String
                    let bio = record.object(forKey: "bio") as? String
                    
                    self?.userRecord = record
                    self?.currentUser.fullName = name ?? "no name in user object"
                    self?.currentUser.bio = bio ?? "no bio in user object"
                    self?.currentUser.userId = userId.recordName
                }
            }
        }
    }
    
    //MARK: Edit User Info in Profile
    func editUserInfo(name: String?, bio: String?, data: Data?, completion: @escaping() -> Void) {
        guard let userRecord = userRecord else { return }

        //MARK: Check if Avatar Image Updated
        if let data = data {
            
            guard let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            
            userRecord["fullName"] = name
            userRecord["bio"] = bio
            userRecord["avatarUrl"] = CKAsset(fileURL: url)
            self.currentUser.bio = bio ?? ""
            self.currentUser.fullName = name ?? ""
            self.currentUser.avatarURL = url.absoluteString
            
            self.saveRecord(record: userRecord)
        } else {
            userRecord["fullName"] = name
            userRecord["bio"] = bio
            self.currentUser.bio = bio ?? ""
            self.currentUser.fullName = name ?? ""
            
            self.saveRecord(record: userRecord)
        }
    }
    
    //MARK: Save Record Data
    func saveRecord(record: CKRecord) {
        DispatchQueue.main.async { [weak self] in
            CKContainer.default().publicCloudDatabase.save(record) { (_, error) in
                guard error == nil else { return }
            }
        }
    }
}

struct CD_Post: Identifiable {
    let id = UUID()
    var CD_userId: String
    var CD_serialNumber: String
    var CD_caption: String
}
