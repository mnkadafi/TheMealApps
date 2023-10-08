//
//  AuthViewModel.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import SwiftUI

class AuthViewModel: ObservableObject {
  @Published var username: String = ""
  @Published var isLoading: Bool = false
  @Published var messageAction: String = ""
  @Published var showAlertMessage: Bool = false
  @Published var isAuthorized: Bool = false
  
  private let bundleID = Bundle.main.bundleIdentifier!
  private let credentialsKey = "SaveUsername"
  private let rememberMeKey = "SaveRememberMe"
  
  private let keyChain = KeyChainManager.shared
  
  init() {
    loadCredentials()
  }
  
  func createNewAccount(username: String, password: String) {
    isLoading = true
    
    if username.isEmpty || password.isEmpty {
      messageAction = "Username and password cannot be empty"
      showAlertMessage.toggle()
      isLoading = false
      return
    }
    
    let base64Password = keyChain.dataToBase64(Data(password.utf8))
    keyChain.saveDataToKeychain(service: bundleID, account: username, password: base64Password) { result in
      switch result {
      case .success(let status):
        if status {
          self.username = username
          self.saveCredentials(username)
          
          DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.isLoading = false
            self.isAuthorized = true
          }
        } else {
          self.messageAction = "Failed to create an account"
        }
      case .failure(let error):
        print("Gagal menyimpan data ke Keychain: \(error)")
        self.messageAction = "Failed to create an account"
        self.isAuthorized = false
        self.afterAction()
      }
    }
  }
  
  func signInAccount(username: String, password: String) {
    isLoading = true
    
    if username.isEmpty || password.isEmpty {
      messageAction = "Username and password cannot be empty"
      showAlertMessage.toggle()
      isLoading = false
      return
    }
    
    keyChain.getDataFromKeyChain(service: bundleID, account: username) { result in
      switch result {
      case .success(let retrievedBase64Password):
        let enteredPassword = self.keyChain.dataToBase64(Data(password.utf8)) // Konversi password pengguna ke bentuk Base64
        if enteredPassword == retrievedBase64Password {
          self.username = username
          self.saveCredentials(username)
          
          DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.isLoading = false
            self.isAuthorized = true
          }
        } else {
          self.messageAction = "Username or password you entered is incorrect / Account not found"
          self.afterAction()
        }
      case .failure(let error):
        print("Gagal menemukan akun dari KeyChain: \(error)")
        self.messageAction = "Username or password you entered is incorrect / Account not found"
        self.afterAction()
      }
    }
  }
  
  func afterAction() {
    self.isLoading = false
    self.showAlertMessage.toggle()
  }
  
  func signOutAccount() {
    isLoading = true
    isAuthorized = false
    deleteCredentials()
    messageAction = "Successfully logged out of the account."
    
    isLoading = false
    showAlertMessage.toggle()
  }
  
  func deleteData() {
    keyChain.deleteDataFromKeychain(account: self.username) { result in
      switch result {
      case .success(let status):
        if status {
          self.messageAction = "Successfully delete account."
          self.isAuthorized = false
          
          self.deleteCredentials()
        } else {
          self.messageAction = "Failed to delete account."
        }
      case .failure(let error):
        print("Terjadi kesalahan saat delete: \(error)")
        self.messageAction = "Failed to delete account."
        self.isAuthorized = false
      }
    }
  }
  
  func loadCredentials() {
    guard let usernameData = UserDefaults.standard.string(forKey: credentialsKey) else { return }
    if usernameData != "" {
      self.username = usernameData
      self.isAuthorized = true
    }
  }
  
  private func saveCredentials(_ username: String) {
    UserDefaults.standard.set(username, forKey: credentialsKey)
  }
  
  func deleteCredentials() {
    self.username = ""
    UserDefaults.standard.removeObject(forKey: credentialsKey)
  }
}
