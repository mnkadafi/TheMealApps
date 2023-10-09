//
//  APIService.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import Foundation
import Alamofire

protocol APIServiceProtocol {
  func fetchMealsByCategory(_ c: String, completion: @escaping(Result<[MealModel]?, Error>) -> Void)
  func fetchMealsByFirstLetter(_ f: String, completion: @escaping(Result<[MealModel]?, Error>) -> Void)
  func fetchMealsById(_ id: String, completion: @escaping(Result<MealModel?, Error>) -> Void)
}

class APIService: APIServiceProtocol {
  static let shared = APIService()
  
  func fetchMealsByCategory(_ c: String, completion: @escaping (Result<[MealModel]?, Error>) -> Void) {
    let parameters = ["c": c]
    AF.request(EndpointsAPI.filterByCategory.url, method: .get, parameters: parameters).response { response in
      switch response.result {
      case .success(let data):
        do {
          guard let data = data else {
            completion(.failure(.noData))
            return
          }
          let mealsResponse = try JSONDecoder().decode(MealResponses.self, from: data)
          let mealModel = self.mapMealResponseToMealModel(from: mealsResponse.meals)
          completion(.success(mealModel))
        } catch {
          completion(.failure(.invalidResponse))
        }
      case .failure:
        completion(.failure(.addressUnreachable(EndpointsAPI.filterByCategory.url)))
      }
    }
  }
  
  func fetchMealsByFirstLetter(_ f: String, completion: @escaping (Result<[MealModel]?, Error>) -> Void) {
    let parameters = ["f": f]
    AF.request(EndpointsAPI.searchByFirstLetter.url, method: .get, parameters: parameters).response { response in
      switch response.result {
      case .success(let data):
        do {
          guard let data = data else {
            completion(.failure(.noData))
            return
          }
          let mealsResponse = try JSONDecoder().decode(MealResponses.self, from: data)
          let mealModel = self.mapMealResponseToMealModel(from: mealsResponse.meals)
          completion(.success(mealModel))
        } catch {
          completion(.failure(.invalidResponse))
        }
      case .failure:
        completion(.failure(.addressUnreachable(EndpointsAPI.filterByCategory.url)))
      }
    }
  }
  
  func fetchMealsById(_ id: String, completion: @escaping(Result<MealModel?, Error>) -> Void) {
    let parameters = ["i": id]
    AF.request(EndpointsAPI.searchById.url, method: .get, parameters: parameters).response { response in
      switch response.result {
      case .success(let data):
        do {
          guard let data = data else {
            completion(.failure(.noData))
            return
          }
          let detailMealResponse = try JSONDecoder().decode(MealResponses.self, from: data)
          let ingredientsAndMeasure = self.mapIngredientsAndMeasure(from: detailMealResponse.meals)
          let detailMealModel = MealModel(id: detailMealResponse.meals.first?.id, title: detailMealResponse.meals.first?.title, drinkAlternate: detailMealResponse.meals.first?.drinkAlternate, category: detailMealResponse.meals.first?.category, area: detailMealResponse.meals.first?.area, instructions: detailMealResponse.meals.first?.instructions, image: detailMealResponse.meals.first?.image, tags: detailMealResponse.meals.first?.tags, youtube: detailMealResponse.meals.first?.youtube, source: detailMealResponse.meals.first?.source, imageSource: detailMealResponse.meals.first?.imageSource, creativeCommonsConfirmed: detailMealResponse.meals.first?.creativeCommonsConfirmed, dateModified: detailMealResponse.meals.first?.dateModified, ingredientsAndMeasure: ingredientsAndMeasure)
          completion(.success(detailMealModel))
        } catch {
          completion(.failure(.invalidResponse))
        }
      case .failure:
        completion(.failure(.addressUnreachable(EndpointsAPI.filterByCategory.url)))
      }
    }
  }
  
  private func mapMealResponseToMealModel(from response: [MealResponse]) -> [MealModel] {
    var mealModel: [MealModel] = []
    
    for item in response {
      mealModel.append(
        MealModel(id: item.id,
                  title: item.title,
                  drinkAlternate: item.drinkAlternate,
                  category: item.category,
                  area: item.area,
                  instructions: item.instructions,
                  image: item.image,
                  tags: item.tags,
                  youtube: item.youtube,
                  source: item.source,
                  imageSource: item.imageSource,
                  creativeCommonsConfirmed: item.creativeCommonsConfirmed,
                  dateModified: item.dateModified,
                  ingredientsAndMeasure: [:]))
    }
    
    return mealModel
  }
  
  func mapIngredientsAndMeasure(from response: [MealResponse]) -> [String: String] {
    var ingredientsAndMeasure: [String: String] = [:]
    
    if let data = response.first {
      let mirror = Mirror(reflecting: data)
      
      for i in 1...20 {
        let ingredientKey = "ingredient\(i)"
        let measureKey = "measure\(i)"
        
        if let ingredientValue = mirror.children.first(where: { $0.label == ingredientKey })?.value as? String,
           let measureValue = mirror.children.first(where: { $0.label == measureKey })?.value as? String,
           !ingredientValue.isEmpty && !measureValue.isEmpty {
          ingredientsAndMeasure[ingredientValue] = measureValue
        }
      }
    }
    
    return ingredientsAndMeasure
  }
}
