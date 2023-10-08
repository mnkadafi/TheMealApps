//
//  HomeView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import SwiftUI
import Kingfisher

struct HomeView: View {
  @Environment(\.defaultMinListRowHeight) var minRowHeight
  @ObservedObject var authViewModel: AuthViewModel
  @ObservedObject var mealsViewModel: MealsViewModel
  @State var showDetailMeal: Bool = false
  @State var shouldShowSettings: Bool = false
  @State var activeSearchBar: Bool = false
  @State var textSearch = ""

  @State var scrollViewSize: CGSize = .zero
  @State var scrollViewSearchSize: CGSize = .zero
  @State var wholeSize: CGSize = .zero
  let spaceName = "scroll"
  let spaceNameSearch = "scrollSearch"
  
  var body: some View {
    GeometryReader { proxy in
      ChildSizeReader(size: $wholeSize) {
        VStack {
          customNavbar
          
          if mealsViewModel.isLoading {
            Spacer()
            LoadingIndicatorView()
            Spacer()
          } else {
            if mealsViewModel.searchMode {
              if mealsViewModel.listSearchMeals.count == 0 {
                Spacer()
                Text("No results based on the first letter on text '\(mealsViewModel.textSearch)'")
                Spacer()
              }
            } else {
              if mealsViewModel.meals.count == 0 {
                Spacer()
                Text("Sorry, currently unable to load data.")
                Spacer()
              }
            }
          }
          
          if mealsViewModel.searchMode {
            if mealsViewModel.listSearchMeals.count != 0 && !mealsViewModel.isLoading {
              ScrollView {
                ChildSizeReader(size: $scrollViewSize) {
                  VStack {
                    Text("Search results based on the first letter on text '\(mealsViewModel.textSearch)'")
                    listSearchContent
                  }
                  .padding(.horizontal)
                  .background(
                    GeometryReader { proxy in
                      Color.clear.preference(
                        key: ViewOffsetKey.self,
                        value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                      )
                    }
                  )
                  .onPreferenceChange(ViewOffsetKey.self, perform: { value in
                    if value >= scrollViewSize.height - (wholeSize.height +  50) {
                      if mealsViewModel.searchMode {
                        if !mealsViewModel.endOfSearchData {
                          guard let lastMeal = mealsViewModel.lastMealSearch else {
                            return
                          }
                          
                          if self.mealsViewModel.shouldLoadMore(isActionSearch: true, mealItem: lastMeal) {
                            self.mealsViewModel.getMoreSearchData()
                          }
                        }
                      }
                    }
                  })
                }
              }
            }
          } else {
            if mealsViewModel.meals.count != 0 {
              ScrollView {
                ChildSizeReader(size: $scrollViewSize) {
                  VStack(spacing: 0) {
                    mealsContent
                    
                    if mealsViewModel.isLoadingLazy {
                      ActivityIndicator(isAnimating: .constant(true), style: .large, color: .gray)
                    }
                  }
                  .padding(.horizontal)
                  .background(
                    GeometryReader { proxy in
                      Color.clear.preference(
                        key: ViewOffsetKey.self,
                        value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                      )
                    }
                  )
                  .onPreferenceChange(ViewOffsetKey.self, perform: { value in
                    if value >= scrollViewSize.height - (wholeSize.height +  50) {
                      if !mealsViewModel.searchMode {
                        if !mealsViewModel.endOfData {
                          guard let lastMeal = mealsViewModel.lastMeal else {
                            return
                          }
                          
                          if self.mealsViewModel.shouldLoadMore(mealItem: lastMeal) {
                            self.mealsViewModel.getMoreData()
                          }
                        }
                      }
                    }
                  })
                }
              }
            }
          }
        }
        .onAppear {
          mealsViewModel.getMealsByCategory("beef")
        }
        .sheet(isPresented: $showDetailMeal) {
          DetailMealView(showDetailMeal: $showDetailMeal, mealID: mealsViewModel.selectedIdDetailMeal)
            .environmentObject(authViewModel)
        }
      }
    }
  }
  
  private var customNavbar: some View {
    VStack(alignment: .leading) {
      HStack {
        if activeSearchBar {
          SearchTextField(text: $textSearch, placeholderText: "Search by first letter...", isForFavorites: false)
            .padding(.trailing)
            .padding([.top, .bottom], 5)
            .frame(height: 50)
            .background(
              RoundedRectangle(cornerRadius: 8, style:
                  .continuous)
              .fill(Color(.init(white: 0.95, alpha: 1)))
            )
            .environmentObject(mealsViewModel)
        } else {
          Text("Meals Apps")
            .font(.largeTitle.weight(.bold))
        }
        
        Spacer()
        
        Button {
          withAnimation(.easeIn) {
            activeSearchBar.toggle()
          }
          
          if !activeSearchBar {
            mealsViewModel.listSearchMeals = []
            mealsViewModel.searchMode = false
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
        
        Button {
          shouldShowSettings.toggle()
        } label: {
          Image(systemName: "gear")
            .foregroundColor(Color.white)
            .padding(10)
            .background(Color.blue)
            .clipShape(Circle())
        }
        .actionSheet(isPresented: $shouldShowSettings) {
          .init(title: Text("Settings"), buttons: [
            .destructive(Text("Sign Out"), action: {
              print("handle sign out")
              authViewModel.signOutAccount()
              mealsViewModel.resetData()
            }),
            .cancel()
          ])
        }
      }
    }
    .padding(.horizontal)
  }
  
  private var mealsContent: some View {
    UIGridView(columns: 2, list: mealsViewModel.meals) { meal in
      RowMealView(showDetailMeal: $showDetailMeal, meal: meal)
        .environmentObject(mealsViewModel)
    }
  }
  
  private var listSearchContent: some View {
    UIGridView(columns: 2, list: mealsViewModel.listSearchMeals) { meal in
      RowMealView(showDetailMeal: $showDetailMeal, meal: meal)
        .environmentObject(mealsViewModel)
    }
  }
}

//struct HomeView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView()
//      .environmentObject(AuthViewModel())
//      .environmentObject(MealsViewModel())
//      .environmentObject(FavoritesViewModel())
//  }
//}


struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}

struct ChildSizeReader<Content: View>: View {
  @Binding var size: CGSize
  let content: () -> Content
  var body: some View {
    ZStack {
      content()
        .background(
          GeometryReader { proxy in
            Color.clear
              .preference(key: SizePreferenceKey.self, value: proxy.size)
          }
        )
    }
    .onPreferenceChange(SizePreferenceKey.self) { preferences in
      self.size = preferences
    }
  }
}

struct SizePreferenceKey: PreferenceKey {
  typealias Value = CGSize
  static var defaultValue: Value = .zero
  
  static func reduce(value _: inout Value, nextValue: () -> Value) {
    _ = nextValue()
  }
}
