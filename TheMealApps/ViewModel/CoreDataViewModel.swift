//
//  CoreDataViewModel.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import Foundation
import CoreData

class CoreDataViewModel: ObservableObject {
  private let container: NSPersistentContainer
  private let containerName: String = "TheMealApps"
  private let entityName: String = "FavoriteMeal"
  
  init() {
    container = NSPersistentContainer(name: containerName)
    container.loadPersistentStores { (_, error) in
      if let error = error {
        print("Error Load Favorites Meal.", error)
      } else {
        print("Success Loaded Favorites meal.")
      }
    }
  }
  
  func getFavoriteMeal(username: String, completion: @escaping ([FavoriteModel]?) -> Void) {
    let fetchRequest = NSFetchRequest<FavoriteMeal>(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: "username == %@", username)
    
    let sort = NSSortDescriptor(key: #keyPath(FavoriteMeal.date), ascending: true)
    fetchRequest.sortDescriptors = [sort]
    
    do {
      let favoriteMeal = try self.container.viewContext.fetch(fetchRequest)
      let favoriteModel = mapFavoriteEntityToFavoriteModel(from: favoriteMeal)
      completion(favoriteModel)
    } catch {
      print("Cannot get favorites meal")
      completion(nil)
    }
  }
  
  func getFavoriteMealByTitle(username: String, title: String, completion: @escaping ([FavoriteModel]?) -> Void) {
    let fetchRequest = NSFetchRequest<FavoriteMeal>(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@ && username == %@", title, username)
    
    let sort = NSSortDescriptor(key: #keyPath(FavoriteMeal.date), ascending: true)
    fetchRequest.sortDescriptors = [sort]
    
    do {
      let favoriteMeal = try self.container.viewContext.fetch(fetchRequest)
      let favoriteModel = mapFavoriteEntityToFavoriteModel(from: favoriteMeal)
      completion(favoriteModel)
    } catch {
      print("Cannot get favorites meal")
      completion(nil)
    }
  }
  
  func checkFavoriteMeal(username: String, meal: MealModel, completion: @escaping (Bool) -> Void) {
    let fetchRequest = NSFetchRequest<FavoriteMeal>(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: "id == %@ && username == %@", meal.id!, username)
    
    do {
      let favoriteMeal = try self.container.viewContext.fetch(fetchRequest)
      let isFavorite = !favoriteMeal.isEmpty
      completion(isFavorite)
    } catch {
      completion(false)
    }
  }
  
  func addFavoriteMeal(username: String, meal: MealModel, completion: @escaping (Bool) -> Void) {
    let fetchRequest = NSFetchRequest<FavoriteMeal>(entityName: self.entityName)
    fetchRequest.predicate = NSPredicate(format: "id == %@ && username == %@", meal.id!, username)
    
    do {
      if let _ = try self.container.viewContext.fetch(fetchRequest).first {
        completion(false)
      } else {
        let entity = FavoriteMeal(context: self.container.viewContext)
        entity.id = meal.id
        entity.title = meal.title
        entity.image = meal.image
        entity.username = username
        entity.date = Date()
      }
      
      self.save()
      completion(true)
    } catch {
      completion(false)
    }
  }
  
  
  func deleteFavoriteMeal(username: String, meal: MealModel, completion: @escaping (Bool) -> Void) {
    let fetchRequest = NSFetchRequest<FavoriteMeal>(entityName: self.entityName)
    fetchRequest.fetchLimit = 1
    fetchRequest.predicate = NSPredicate(format: "id == %@ && username == %@", meal.id!, username)
    
    do {
      let objectsToDelete = try self.container.viewContext.fetch(fetchRequest)
      for object in objectsToDelete {
        self.container.viewContext.delete(object)
      }
      
      self.save()
      completion(true)
    } catch {
      completion(false)
    }
  }
  
  private func save() {
    do {
      try container.viewContext.save()
    } catch let error {
      print("Error saving to Core Data. \(error)")
    }
  }
  
  private func mapFavoriteEntityToFavoriteModel(from entity: [FavoriteMeal]) -> [FavoriteModel] {
    var mealModel: [FavoriteModel] = []
    
    for item in entity {
      mealModel.append(FavoriteModel(id: item.id, title: item.title, image: item.image))
    }
    
    return mealModel
  }
}
