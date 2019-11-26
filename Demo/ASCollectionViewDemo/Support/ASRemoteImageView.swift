// ASCollectionView. Created by Apptek Studios 2019

import Foundation
import SwiftUI

/// WARNING: ASRemoteImageView was created for the purposes of this demo project, and is not intended for production use
struct ASRemoteImageView: View
{
	/// WARNING: ASRemoteImageView was created for the purposes of this demo project, and is not intended for production use
	init(_ url: URL)
	{
		self.url = url
		imageLoader = ASRemoteImageManager.shared.imageLoader(for: url)
	}

	let url: URL
	@ObservedObject
	var imageLoader: ASRemoteImageLoader

	var content: some View
	{
		ZStack
		{
			Color(.secondarySystemBackground)
			Image(systemName: "photo")
			self.imageLoader.image.map
			{ image in
				Image(uiImage: image)
					.resizable()
			}.transition(AnyTransition.opacity.animation(Animation.default))
		}
		.compositingGroup()
	}

	var body: some View
	{
		content
	}
}
