//
//  ContentView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var authViewModel = AuthViewModel()
  @ObservedObject var mealsViewModel = MealsViewModel()
  @ObservedObject var favoritesViewModel = FavoritesViewModel()
  @State var tabSelection: Tabs = .home
  
  init() {
    UITabBar.appearance().backgroundColor = UIColor.init(white: 0.95, alpha: 1)
  }
  
  var body: some View {
    NavigationView {
      Group {
        if authViewModel.isAuthorized {
          TabView(selection: $tabSelection) {
            HomeView(authViewModel: authViewModel, mealsViewModel: mealsViewModel)
              .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
              }.tag(Tabs.home)
            
            FavoritesView(authViewModel: authViewModel, favoritesViewModel: favoritesViewModel)
              .tabItem {
                Image(systemName: "heart.fill")
                Text("Favorites")
              }.tag(Tabs.favorite)
          }
          .navigationBarTitle("")
          .navigationBarHidden(true)
          .accentColor(.blue)
        } else {
          LoginView(authViewModel: authViewModel)
        }
      }
    }
  }
  
  enum Tabs {
    case home, favorite
  }
  
  func returnNaviBarTitle(tabSelection: Tabs) -> String {
    switch tabSelection {
    case .home:
      return "Meals App"
    case .favorite:
      return "Favorites"
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(AuthViewModel())
      .environmentObject(MealsViewModel())
      .environmentObject(FavoritesViewModel())
  }
}
