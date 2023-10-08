//
//  FavoriteView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import SwiftUI
import Combine

struct FavoritesView: View {
  @ObservedObject var authViewModel: AuthViewModel
  @ObservedObject var favoritesViewModel: FavoritesViewModel
  @State var showDetailMeal: Bool = false
  @State var activeSearchBar: Bool = false
  @State var textSearch = ""
  
  var body: some View {
    VStack {
      customNavbar
      
      if favoritesViewModel.isLoading {
        Spacer()
        LoadingIndicatorView()
        Spacer()
      } else {
        if favoritesViewModel.searchMode {
          if favoritesViewModel.listSearchMeals.count == 0 {
            Spacer()
            Text("No results based on the text '\(favoritesViewModel.textSearch)'")
            Spacer()
          }
        } else {
          if favoritesViewModel.meals.count == 0 {
            Spacer()
            Text("Your favorite foods are shown here.")
            Spacer()
          }
        }
      }
      
      if favoritesViewModel.searchMode {
        if favoritesViewModel.listSearchMeals.count != 0 && !favoritesViewModel.isLoading {
          ScrollView {
            VStack {
              Text("Search results based on the text '\(favoritesViewModel.textSearch)'")
              listSearchContent
            }
            .padding(.horizontal)
          }
        }
      } else {
        if favoritesViewModel.meals.count != 0 {
          ScrollView {
            VStack(spacing: 24) {
              mealsContent
            }
            .padding(.horizontal)
          }
        }
      }
    }
    .sheet(isPresented: $showDetailMeal, onDismiss: {
      favoritesViewModel.getFavoritesMeal(authViewModel.username)
    }) {
      DetailMealView(showDetailMeal: $showDetailMeal, mealID: favoritesViewModel.selectedIdDetailMeal)
        .environmentObject(authViewModel)
    }
    .onAppear {
      favoritesViewModel.getFavoritesMeal(authViewModel.username)
    }
  }
  
  private var customNavbar: some View {
    VStack(alignment: .leading) {
      HStack {
        if activeSearchBar {
          SearchTextField(text: $textSearch, placeholderText: "Search by meal title...", isForFavorites: true)
            .padding(.trailing)
            .padding([.top, .bottom], 5)
            .frame(height: 50)
            .background(
              RoundedRectangle(cornerRadius: 8, style:
                  .continuous)
              .fill(Color(.init(white: 0.95, alpha: 1)))
            )
            .environmentObject(authViewModel)
            .environmentObject(favoritesViewModel)
        } else {
          Text("Favorites Meal")
            .font(.largeTitle.weight(.bold))
        }
        
        Spacer()
        
        Button {
          withAnimation(.easeIn) {
            activeSearchBar.toggle()
          }

          if !activeSearchBar {
            favoritesViewModel.listSearchMeals = []
            favoritesViewModel.searchMode = false
            self.textSearch = ""
          }
        } label: {
          if activeSearchBar {
            Text("Cancel")
              .foregroundColor(Color.blue)
          } else {
            Image(systemName: "magnifyingglass")
              .foregroundColor(Color.white)
              .padding(10)
              .background(Color.blue)
              .clipShape(Circle())
          }
        }
      }
    }
    .padding(.horizontal)
  }
  
  private var mealsContent: some View {
    ForEach(favoritesViewModel.meals) { meal in
      RowFavoritesView(showDetailMeal: $showDetailMeal, meal: meal)
        .environmentObject(favoritesViewModel)
    }
  }
  
  private var listSearchContent: some View {
    
    ForEach(favoritesViewModel.listSearchMeals) { meal in
      RowFavoritesView(showDetailMeal: $showDetailMeal, meal: meal)
        .environmentObject(favoritesViewModel)
    }
  }
}

struct FavoritesView_Previews: PreviewProvider {
  static var previews: some View {
    FavoritesView(authViewModel: AuthViewModel(), favoritesViewModel: FavoritesViewModel())
  }
}
