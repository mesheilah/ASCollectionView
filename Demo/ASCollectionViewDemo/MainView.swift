// ASCollectionView. Created by Apptek Studios 2019

import ASNavigationView
import SwiftUI

struct MainView: View
{
	var body: some View
	{
		ASNavigationView
		{
			List
			{
				Section(header: Text("Example screens"))
				{
					ASNavigationButton(screenName: "PHOTOGRID", destination: PhotoGridScreen())
					{
						Image(systemName: "1.square.fill")
						Text("Photo grid (with edit mode, selection)")
					}
					ASNavigationButton(destination: AppStoreScreen())
					{
						Image(systemName: "2.square.fill")
						Text("App Store Layout")
					}
					ASNavigationButton(destination: TagsScreen())
					{
						Image(systemName: "3.square.fill")
						Text("Tags Flow Layout")
					}
					ASNavigationButton(destination: RemindersScreen())
					{
						Image(systemName: "4.square.fill")
						Text("Reminders Layout")
					}
					ASNavigationButton(destination: WaterfallScreen())
					{
						Image(systemName: "5.square.fill")
						Text("Waterfall Layout")
					}
					ASNavigationButton(destination: InstaFeedScreen())
					{
						Image(systemName: "6.square.fill")
						Text("Insta Feed (table view)")
					}
					ASNavigationButton(destination: MagazineLayoutScreen())
					{
						Image(systemName: "7.square.fill")
						Text("Magazine Layout (with context menu)")
					}
					ASNavigationButton(destination: AdjustableGridScreen())
					{
						Image(systemName: "8.square.fill")
						Text("Adjustable layout")
					}
				}
				Section(header: Text("Modified examples"))
				{
					ASNavigationButton(screenName: "PHOTOGRID", destination: PhotoGridScreen(startingAtBottom: true))
					{
						Image(systemName: "hammer")
						Text("Photo grid (Starting at bottom)")
					}
					ASNavigationButton(destination: TagsScreen(shrinkToSize: true))
					{
						Image(systemName: "hammer")
						Text("Tags in self-sizing collection")
					}
				}
			}
			.navigationBarTitle("Demo App")
		}
	}
}

struct MainView_Previews: PreviewProvider
{
	static var previews: some View
	{
		MainView()
	}
}
