// ASCollectionView. Created by Apptek Studios 2019

import ASCollectionView
import SwiftUI
import UIKit

struct PhotoGridScreen: View
{
	@State var data: [Post] = DataSource.postsForGridSection(1, number: 1000)
	@State var selectedItems: IndexSet = []

	@Environment(\.editMode) private var editMode
	var isEditing: Bool
	{
		editMode?.wrappedValue.isEditing ?? false
	}

	typealias SectionID = Int

	var section: ASCollectionViewSection<SectionID>
	{
		ASCollectionViewSection(
			id: 0,
			data: data,
			onCellEvent: onCellEvent,
			onDragDropEvent: onDragDropEvent,
			itemProvider: { item in
				//Example of returning a custom item provider (eg. to support drag-drop to other apps)
				NSItemProvider(object: item.url as NSURL)
		})
		{ item, state in
			DynamicNavigationButton(
				destination: DynamicNavigationDismissButton.popToRoot {
					Text("Item number \(item.offset)")
				}
			) {
				ZStack(alignment: .bottomTrailing)
				{
					GeometryReader
						{ geom in
							ASRemoteImageView(item.squareThumbURL)
								.aspectRatio(1, contentMode: .fill)
								.frame(width: geom.size.width, height: geom.size.height)
								.clipped()
								.opacity(state.isSelected ? 0.7 : 1.0)
					}
					
					if state.isSelected
					{
						ZStack
							{
								Circle()
									.fill(Color.blue)
								Circle()
									.strokeBorder(Color.white, lineWidth: 2)
								Image(systemName: "checkmark")
									.font(.system(size: 10, weight: .bold))
									.foregroundColor(.white)
						}
						.frame(width: 20, height: 20)
						.padding(10)
					}
				}
			}
		}
	}

	var body: some View
	{
		DynamicNavigationScreen {
			ASCollectionView(
				selectedItems: $selectedItems,
				section: section)
				.layout(self.layout)
				.navigationBarTitle("Explore", displayMode: .inline)
				.navigationBarItems(
					trailing:
					HStack(spacing: 20)
					{
						if self.isEditing
						{
							Button(action: {
								self.data.remove(atOffsets: self.selectedItems)
							})
							{
								Image(systemName: "trash")
							}
						}
						
						EditButton()
				})
		}
	}

	func onCellEvent(_ event: CellEvent<Post>)
	{
		switch event
		{
		case let .onAppear(item):
			ASRemoteImageManager.shared.load(item.squareThumbURL)
		case let .onDisappear(item):
			ASRemoteImageManager.shared.cancelLoad(for: item.squareThumbURL)
		case let .prefetchForData(data):
			for item in data
			{
				ASRemoteImageManager.shared.load(item.squareThumbURL)
			}
		case let .cancelPrefetchForData(data):
			for item in data
			{
				ASRemoteImageManager.shared.cancelLoad(for: item.squareThumbURL)
			}
		}
	}

	func onDragDropEvent(_ event: DragDrop<Post>)
	{
		switch event
		{
		case let .onRemoveItem(indexPath):
			data.remove(at: indexPath.item)
		case let .onAddItems(items, indexPath):
			data.insert(contentsOf: items, at: indexPath.item)
		}
	}
}

extension PhotoGridScreen
{
	var layout: ASCollectionLayout<Int>
	{
		ASCollectionLayout(scrollDirection: .vertical, interSectionSpacing: 0)
		{
			ASCollectionLayoutSection
			{ environment in
				let isWide = environment.container.effectiveContentSize.width > 500
				let gridBlockSize = environment.container.effectiveContentSize.width / (isWide ? 5 : 3)
				let gridItemInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
				let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(gridBlockSize), heightDimension: .absolute(gridBlockSize))
				let item = NSCollectionLayoutItem(layoutSize: itemSize)
				item.contentInsets = gridItemInsets
				let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(gridBlockSize), heightDimension: .absolute(gridBlockSize * 2))
				let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize, subitem: item, count: 2)

				let featureItemSize = NSCollectionLayoutSize(widthDimension: .absolute(gridBlockSize * 2), heightDimension: .absolute(gridBlockSize * 2))
				let featureItem = NSCollectionLayoutItem(layoutSize: featureItemSize)
				featureItem.contentInsets = gridItemInsets

				let fullWidthItemSize = NSCollectionLayoutSize(widthDimension: .absolute(environment.container.effectiveContentSize.width), heightDimension: .absolute(gridBlockSize * 2))
				let fullWidthItem = NSCollectionLayoutItem(layoutSize: fullWidthItemSize)
				fullWidthItem.contentInsets = gridItemInsets

				let verticalAndFeatureGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(gridBlockSize * 2))
				let verticalAndFeatureGroupA = NSCollectionLayoutGroup.horizontal(layoutSize: verticalAndFeatureGroupSize, subitems: isWide ? [verticalGroup, verticalGroup, featureItem, verticalGroup] : [verticalGroup, featureItem])
				let verticalAndFeatureGroupB = NSCollectionLayoutGroup.horizontal(layoutSize: verticalAndFeatureGroupSize, subitems: isWide ? [verticalGroup, featureItem, verticalGroup, verticalGroup] : [featureItem, verticalGroup])

				let rowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(gridBlockSize))
				let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowGroupSize, subitem: item, count: isWide ? 5 : 3)

				let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(gridBlockSize * 8))
				let outerGroup = NSCollectionLayoutGroup.vertical(layoutSize: outerGroupSize, subitems: [verticalAndFeatureGroupA, rowGroup, fullWidthItem, verticalAndFeatureGroupB, rowGroup])

				let section = NSCollectionLayoutSection(group: outerGroup)
				return section
			}
		}
	}
}

struct GridView_Previews: PreviewProvider
{
	static var previews: some View
	{
		PhotoGridScreen()
	}
}


struct DynamicNavigationView<Content: View>: View {
	var content: Content
	
	init(@ViewBuilder _ content: (() -> Content)) {
		self.content = content()
	}
	
	var body: some View {
		NavigationView {
			DynamicNavigationScreen(screenName: dynamicNavigationViewMainScreen) {
				content
			}
		}
	}
}

let dynamicNavigationViewMainScreen = "ASDynamicNavigationViewMainScreen"

struct DynamicNavigationScreen<Content: View>: View {
	var screenName: String?
	var content: Content
	@State var currentContent: AnyView?
	
	var hasContent: Binding<Bool> {
		Binding(get: { self.currentContent != nil }, set: { if !$0 { self.currentContent = nil } })
	}
	
	init(screenName: String? = nil, @ViewBuilder _ content: (() -> Content)) {
		self.screenName = screenName
		self.content = content()
	}
	
	func modifyEnvironment<T: View>(_ view: T) -> some View {
		view.transformEnvironment(\.dynamicNavState) { state in
			state.addScreen(
				DynamicNavState.Screen(name: self.screenName,
									   push: { self.currentContent = $0 },
									   pop: { self.currentContent = nil })
			)
		}
	}
	
	var body: some View {
		VStack {
			modifyEnvironment(content)
			NavigationLink(destination: modifyEnvironment(currentContent), isActive: hasContent) { EmptyView() }
		}
	}
}

struct DynamicNavigationButton<Label: View, Destination: View>: View {
	var destination: Destination
	var label: Label
	@Environment(\.dynamicNavState) var dynamicNavState
	
	init(destination: Destination, @ViewBuilder label: (() -> Label)) {
		self.destination = destination
		self.label = label()
	}
	
	var body: some View {
		Button(action: {
			self.dynamicNavState.pushView(self.destination)
		}) {
			label
		}
		.buttonStyle(PlainButtonStyle())
	}
}


struct DynamicNavigationDismissButton<Label: View>: View {
	var label: Label
	var dismissToScreenNamed: String? //If nil, defaults to nearest screen
	@Environment(\.dynamicNavState) var dynamicNavState
	
	init(dismissToScreenNamed: String? = nil, @ViewBuilder label: (() -> Label)) {
		self.dismissToScreenNamed = dismissToScreenNamed
		self.label = label()
	}
	
	var body: some View {
		Button(action: {
			self.dynamicNavState.popToScreen(named: self.dismissToScreenNamed)
		}) {
			label
		}
		.buttonStyle(PlainButtonStyle())
	}
	
	static func popToRoot(@ViewBuilder label: (() -> Label)) -> Self {
		self.init(dismissToScreenNamed: dynamicNavigationViewMainScreen, label: label)
	}
}

struct DynamicNavState {
	var screens: [Screen] = []
	struct Screen {
		var name: String?
		var push: ((AnyView) -> ())
		var pop: (() -> ())
	}
	
	//Used to construct the environment
	mutating func addScreen(_ screen: Screen) {
		screens.append(screen)
	}
	
	//Used to present a view
	func pushView<Content: View>(_ view: Content, toScreenNamed screenName: String? = nil) {
		let erasedView = AnyView(view)
		if let screenName = screenName,
		   let screen = screens.last(where: { $0.name == screenName }) {
			screen.push(erasedView)
		} else {
			if screenName != nil { print("Attempted to push to screenName that doesn't exist in the hierarchy, pushing to nearest screen") }
			guard let screen = screens.last else {
				return
			}
			screen.push(erasedView)
		}
	}
	
	//Used to pop to the named screen (or nearest screen)
	func popToScreen(named screenName: String?) {
		if let screenName = screenName {
			guard
				let screenIndex = screens.lastIndex(where: { $0.name == screenName })
				else {
					print("Attempted to dismiss to screenName that doesn't exist in the hierarchy")
					return
			}
			let screensToPop = screens.suffix(from: screenIndex).reversed()
			screensToPop.forEach { $0.pop() }
			#warning("This still won't pop further than one up the hierarchy")
		} else {
			guard let screen = screens.last else {
				return
			}
			screen.pop()
		}
	}
}

struct EnvironmentKeyASDynamicNavState: EnvironmentKey
{
	static let defaultValue: DynamicNavState = DynamicNavState()
}

extension EnvironmentValues
{
	var dynamicNavState: DynamicNavState
	{
		get { return self[EnvironmentKeyASDynamicNavState.self] }
		set { self[EnvironmentKeyASDynamicNavState.self] = newValue }
	}
}
