//
//  DetailMealViewModel.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import Foundation

class DetailMealViewModel: ObservableObject {
  @Published var detailMeal: MealModel?
  @Published var messageAction: String = ""
  @Published var isFavorite: Bool = false
  @Published var isLoading: Bool = false
  @Published var showAlertMessage: Bool = false
  
  private let apiService: APIServiceProtocol
  private let coreDataViewModel = CoreDataViewModel()
  
  init(apiService: APIServiceProtocol = APIService()) {
    self.apiService = apiService
  }
  
  func fetchMealsById(_ username: String, _ id: String) {
    isLoading = true
    apiService.fetchMealsById(id) { result in
      switch result {
      case .success(let meal):
        guard let meal = meal else {
          self.isLoading = false
          return
        }
        
        DispatchQueue.main.async {
          self.detailMeal = meal
          self.isLoading = false
          self.checkFavoriteMeal(username, meal)
        }
      case .failure(let error):
        print(error)
        self.isLoading = false
      }
    }
  }
  
  func checkFavoriteMeal(_ username: String, _ meal: MealModel) {
    coreDataViewModel.checkFavoriteMeal(username: username, meal: meal, completion: { result in
      DispatchQueue.main.async {
        self.isFavorite = result
      }
    })
  }
  
  func addFavoriteMeal(_ username: String, _ meal: MealModel) {
    coreDataViewModel.addFavoriteMeal(username: username, meal: meal) { result in
      DispatchQueue.main.async {
        if result {
          self.messageAction = "successfully favorite the meal"
          self.isFavorite = true
        } else {
          self.messageAction = "Failed favorite the meal"
        }
      }
    }
  }
  
  func deleteFavoriteMeal(_ username: String, _ meal: MealModel) {
    coreDataViewModel.deleteFavoriteMeal(username: username, meal: meal) { result in
      DispatchQueue.main.async {
        if result {
          self.messageAction = "Successfully delete favorite meal"
          self.isFavorite = false
        } else {
          self.messageAction = "Failed to delete favorite meal"
        }
      }
    }
  }
}
