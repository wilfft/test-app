import SwiftUI

struct VideoFeedContentView: View {
    @ObservedObject var viewModel: VideoListViewModel

    var body: some View {
        switch viewModel.state {
        case .idle:
            Text(NSLocalizedString("waiting", comment: ""))
        case .loading:
            ProgressView(NSLocalizedString("loading", comment: ""))
        case .loaded(let videos):
            ScrollView {
                LazyVStack {
                    ForEach(videos, id: \.id) { video in
                        NavigationLink {
                            VideoPlayerView(video: video)
                        } label: {
                            VideoCard(video: video)
                        }
                    }
                }
            }
        case .error(let networkError):
            VStack {
                Text(NSLocalizedString("error_loading_videos", comment: ""))
                    .font(.headline)
                Text(networkError.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.red)
                Button(NSLocalizedString("try_again", comment: "")) {
                    Task {
                        await viewModel.loadVideos()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}
