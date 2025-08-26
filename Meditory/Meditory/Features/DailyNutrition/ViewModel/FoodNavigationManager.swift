//
//  NavigationManager.swift
//  Meditory
//
//  Created by 이치훈 on 8/26/25.
//

import Foundation

enum FoodScreen {
  case mealList
  case mealDetail
  case addMeal
}

class FoodNavigationManager: ObservableObject {
  @Published var currentScreen: FoodScreen = .mealDetail
  
  func navigateTo(_ screen: FoodScreen) {
    currentScreen = screen
  }
  
  func isCurrentScreen(_ screen: FoodScreen) -> Bool {
      defer {
          print("current: \(currentScreen)")
          print("input: \(screen)")
      }
      return currentScreen == screen
  }
}
