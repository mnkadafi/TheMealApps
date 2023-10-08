//
//  MealsViewModel.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import SwiftUI
import Alamofire

class MealsViewModel: ObservableObject {
  @Published var meals: [MealModel] = []
  @Published var lastMeal: MealModel?
  @Published var lastMealSearch: MealModel?
  @Published var remainingData: [MealModel] = []
  @Published var listSearchMeals: [MealModel] = []
  @Published var remainingSearchData: [MealModel] = []
  @Published var selectedIdDetailMeal: String = ""
  @Published var searchMode: Bool = false
  @Published var isLoading: Bool = false
  @Published var isLoadingLazy: Bool = false
  @Published var textSearch: String = ""
  @Published var endOfData = false
  @Published var endOfSearchData = false
  
  let batchSize = 10
  let apiService: APIServiceProtocol
  
  init(apiService: APIServiceProtocol = APIService()) {
    self.apiService = apiService
  }
  
  func getMealsByCategory(_ category: String) {
    isLoading = true
    apiService.fetchMealsByCategory(category) { meals in
      switch meals {
      case .success(let meal):
        guard let mealBatch = meal else { return }
        
        DispatchQueue.main.async {
          self.meals = Array(mealBatch.prefix(self.batchSize))
          self.remainingData = Array(mealBatch.dropFirst(self.batchSize))
          
          self.isLoading = false
          self.lastMeal = self.meals.last
          self.endOfData = self.remainingData.isEmpty
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  
  func fetchMealsByFirstLetter(_ firstLetter: String) {
    isLoading = true
    searchMode = true
    if let firstLetter = getFirstCharacterAndCheckValidity(firstLetter) {
      apiService.fetchMealsByFirstLetter(firstLetter) { meals in
        switch meals {
        case .success(let meal):
          guard let mealBatch = meal else {
            self.isLoading = false
            return
          }
          
          DispatchQueue.main.async {
            self.listSearchMeals = Array(mealBatch.prefix(self.batchSize))
            self.remainingSearchData = Array(mealBatch.dropFirst(self.batchSize))
            
            self.isLoading = false
            self.lastMealSearch = self.listSearchMeals.last
            self.endOfSearchData = self.remainingSearchData.isEmpty
          }
        case .failure(let error):
          print(error)
        }
      }
    } else {
      self.isLoading = false
    }
  }
  
  func getFirstCharacterAndCheckValidity(_ input: String) -> String? {
    guard let firstCharacter = input.first else {
      return nil
    }
    
    if firstCharacter.isLetter {
      return String(firstCharacter)
    } else {
      return nil
    }
  }
  
  func getMoreData() {
    if !remainingData.isEmpty {
      // Menambahkan 10 data dari sisa data
      if(self.endOfData == false) {
        print("MORE MAINN DATA")
        let newData = Array(self.remainingData.prefix(self.batchSize))
        self.meals += newData
        self.remainingData = Array(self.remainingData.dropFirst(self.batchSize))
        self.lastMeal = self.meals.last
        
        // Mengatur ulang endOfData jika tidak ada lagi sisa data
        self.endOfData = self.remainingData.isEmpty
      }
    }
  }
  
  func getMoreSearchData() {
    if !remainingSearchData.isEmpty {
      // Menambahkan 10 data dari sisa data
      if(self.endOfSearchData == false) {
        print("MORE SEARCH DATA")
        let newData = Array(self.remainingSearchData.prefix(self.batchSize))
        self.listSearchMeals += newData
        self.remainingSearchData = Array(self.remainingSearchData.dropFirst(self.batchSize))
        self.lastMealSearch = self.listSearchMeals.last
        
        // Mengatur ulang endOfData jika tidak ada lagi sisa data
        self.endOfSearchData = self.remainingSearchData.isEmpty
      }
    }
  }
  
  func shouldLoadMore(isActionSearch: Bool = false, mealItem: MealModel) -> Bool {
    if let lastId = isActionSearch ? listSearchMeals.last?.id : meals.last?.id {
      if mealItem.id == lastId {
        return true
      } else {
        return false
      }
    }
    
    return false
  }
  
  func resetData() {
    meals = []
    lastMeal = nil
    lastMealSearch = nil
    remainingData = []
    listSearchMeals = []
    remainingSearchData = []
    selectedIdDetailMeal = ""
    searchMode = false
    isLoading = false
    isLoadingLazy = false
    textSearch = ""
    endOfData = false
    endOfSearchData = false
  }
}

public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
  public static let get = HTTPMethod(rawValue: "GET")
  public static let post = HTTPMethod(rawValue: "POST")
  
  public let rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

