// ASCollectionView. Created by Apptek Studios 2019

import Foundation
import SwiftUI

struct ASNavigationState
{
	weak var coordinator: ASNavigationCoordinator?
	func push<T: View>(_ view: T, withScreenName screenName: String? = nil)
	{
		coordinator?.push(view, withScreenName: screenName)
	}

	func pop(toScreenNamed screenName: String? = nil)
	{
		coordinator?.pop(toScreenNamed: screenName)
	}

	func popToRoot()
	{
		coordinator?.popToRoot()
	}
}

struct EnvironmentKeyASNavigationState: EnvironmentKey
{
	static let defaultValue: ASNavigationState = ASNavigationState()
}

extension EnvironmentValues
{
	var dynamicNavState: ASNavigationState
	{
		get { return self[EnvironmentKeyASNavigationState.self] }
		set { self[EnvironmentKeyASNavigationState.self] = newValue }
	}
}
