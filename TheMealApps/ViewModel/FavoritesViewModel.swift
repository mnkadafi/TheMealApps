//
//  FavoritesViewModel.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import Foundation

class FavoritesViewModel: ObservableObject {
  @Published var meals: [FavoriteModel] = []
  @Published var displayedMeals: [FavoriteModel] = []
  @Published var listSearchMeals: [FavoriteModel] = []
  @Published var selectedIdDetailMeal: String = ""
  @Published var searchMode: Bool = false
  @Published var errorMessage: String = ""
  @Published var isLoading: Bool = false
  @Published var textSearch: String = ""
  
  private let coreDataViewModel = CoreDataViewModel()
  
  func getFavoritesMeal(_ username: String) {
    coreDataViewModel.getFavoriteMeal(username: username) { meal in
      guard let meal = meal else { return }
      self.meals = meal
    }
  }
  
  func searchFavoriteMealByTitle(_ username: String, mealTitle: String) {
    searchMode = true
    coreDataViewModel.getFavoriteMealByTitle(username: username, title: mealTitle) { meal in
      guard let meal = meal else { return }
      self.listSearchMeals = meal
    }
  }
  
  func resetData() {
    meals = []
    displayedMeals = []
    listSearchMeals = []
    selectedIdDetailMeal = ""
    searchMode = false
    errorMessage = ""
    isLoading = false
    textSearch = ""
  }
}
