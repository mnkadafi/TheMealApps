//
//  TheMealAppsTests.swift
//  TheMealAppsTests
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import XCTest
@testable import TheMealApps

final class TheMealAppsTests: XCTestCase {
  var viewModel: MealsViewModel!
  var detailViewModel: DetailMealViewModel!
  
  override func setUpWithError() throws {
    super.setUp()
    viewModel = MealsViewModel()
  }
  
  override func tearDownWithError() throws {
    viewModel = nil
    super.tearDown()
  }
  
  func testFailureFetchMealsByCategory() {
    let mockServiceAPI = MockNetworkAPIService()
    mockServiceAPI.result = .failure(.invalidResponse)
    
    viewModel = MealsViewModel(apiService: mockServiceAPI)
    viewModel.getMealsByCategory("")
    
    let expectation = XCTestExpectation(description: "Fetch Meals By Category")
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      XCTAssertTrue(self.viewModel.meals.isEmpty, "Fetch meals should be empty")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testSuccessFetchMealsByCategory() {
    let mockServiceAPI = MockNetworkAPIService()
    guard let mealsByCategory = mockServiceAPI.mealsByCategory() else { return }
    mockServiceAPI.result = .success(mealsByCategory)
    
    viewModel = MealsViewModel(apiService: mockServiceAPI)
    viewModel.getMealsByCategory("beef")
    
    let expectation = XCTestExpectation(description: "Fetch Meals By Category")
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      XCTAssertTrue(!self.viewModel.meals.isEmpty, "List search meals should not be nil")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testFailureFetchMealsByFirstLetter() {
    let mockServiceAPI = MockNetworkAPIService()
    mockServiceAPI.result = .failure(.invalidResponse)
    
    viewModel = MealsViewModel(apiService: mockServiceAPI)
    viewModel.fetchMealsByFirstLetter("")
    
    let expectation = XCTestExpectation(description: "Fetch Meals By First Letter")
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      XCTAssertTrue(self.viewModel.listSearchMeals.isEmpty, "List search meal should be nil on failure")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testSuccessFetchMealsByFirstLetter() {
    viewModel = MealsViewModel()
    viewModel.fetchMealsByFirstLetter("egg")
    
    let expectation = XCTestExpectation(description: "Fetch Meals By First Letter")
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      XCTAssertTrue(!self.viewModel.listSearchMeals.isEmpty, "Fetch meals should not be empty")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testFailureFetchMealsById() {
    let mockServiceAPI = MockNetworkAPIService()
    mockServiceAPI.resultDetail = .failure(.invalidResponse)
    detailViewModel = DetailMealViewModel(apiService: mockServiceAPI)
    
    let expectation = XCTestExpectation(description: "Fetch Meals By Id")
    
    detailViewModel.fetchMealsById("kadafi", "")
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      XCTAssertNil(self.detailViewModel.detailMeal, "Detail meal should be nil on failure")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testSuccessFetchMealsById() {
    detailViewModel = DetailMealViewModel()
    let expectation = XCTestExpectation(description: "Fetch Meals By Id")
    detailViewModel.fetchMealsById("kadafi", "52772")
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
      XCTAssertNotNil(self.detailViewModel.detailMeal, "Detail Meals should be not nil on success")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
}
