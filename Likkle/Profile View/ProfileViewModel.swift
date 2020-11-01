//
//  ProfileViewModel.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/21/20.
//

import Combine
import Foundation
import UIKit

class ProfileViewModel: ObservableObject {
    
    @Published var pickerBool: Bool = false
    @Published var newUsername: String = ""
    @Published var bioText: String = ""
    @Published var showAlert: Bool = false
    @Published var showAddPostModal: Bool = false
    @Published var images: [UIImage] = []
}
