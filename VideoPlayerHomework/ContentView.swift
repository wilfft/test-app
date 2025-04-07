import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = VideoListViewModel()
    
    var body: some View {
        NavigationStack {
            VideoFeedContentView(viewModel: viewModel)
                .navigationTitle("Feed")
                .navigationBarTitleDisplayMode(.automatic)
                .padding()
                .onAppear {
                    Task {
                        await viewModel.loadVideos()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
