//
//  Enum+Endpoint.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import Foundation

enum EndpointsAPI: String {
  private var MEAL_BASE_URL: String { return "https://www.themealdb.com" }
  
  case filterByCategory = "/api/json/v1/1/filter.php"
  case searchByFirstLetter = "/api/json/v1/1/search.php"
  case searchById = "/api/json/v1/1/lookup.php"

  var url: URL {
    guard let encodedRawValue = self.rawValue.removingPercentEncoding,
          let url = URL(string: MEAL_BASE_URL) else {
      preconditionFailure("The url used in \(EndpointsAPI.self) is not valid")
    }
    
    return url.appendingPathComponent(encodedRawValue)
  }
}

enum Error: LocalizedError {
  case addressUnreachable(URL)
  case invalidResponse
  case noData
  
  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "Invalid response from the server"
    case .addressUnreachable(let url):
      return "Unreachable URL: \(url.absoluteString)"
    case .noData:
      return "No response data from server"
    }
  }
}
