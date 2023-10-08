//
//  KeyChainManager.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 07/10/23.
//

import SwiftUI
import LocalAuthentication

enum KeyChainError: LocalizedError {
  case duplicateItem
  case unknown(OSStatus)
}

final class KeyChainManager {
  static let shared = KeyChainManager()
  
  // Simpan data dalam bentuk Base64 ke dalam Keychain
  func saveDataToKeychain(service: String, account: String, password: String, completion: @escaping (Result<Bool, KeyChainError>) -> Void) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecValueData as String: base64ToData(password)
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    
    guard status != errSecDuplicateItem else {
      completion(.failure(.duplicateItem))
      return
    }
    
    guard status == errSecSuccess else {
      completion(.failure(.unknown(status)))
      return
    }
    
    completion(.success(true))
  }
  
  // Mendapatkan data dalam bentuk Base64 dari Keychain
  func getDataFromKeyChain(service: String, account: String, completion: @escaping (Result<String?, KeyChainError>) -> Void) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    
    guard status == errSecSuccess, let data = item as? Data else {
      completion(.failure(.unknown(status)))
      return
    }
    
    let base64Data = dataToBase64(data)
    completion(.success(base64Data))
  }
  
  // Menghapus data dari Keychain berdasarkan account
  func deleteDataFromKeychain(account: String, completion: @escaping (Result<Bool, KeyChainError>) -> Void) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess else {
      completion(.failure(.unknown(status)))
      return
    }
    
    completion(.success(true))
  }
  
  // Fungsi untuk mengonversi data menjadi Base64
  func dataToBase64(_ data: Data) -> String {
    return data.base64EncodedString()
  }
  
  // Fungsi untuk mengonversi Base64 kembali ke data
  func base64ToData(_ base64String: String) -> Data {
    return Data(base64Encoded: base64String) ?? Data()
  }
}
