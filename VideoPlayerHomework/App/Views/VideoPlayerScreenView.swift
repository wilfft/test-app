import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @StateObject var viewModel: FullVideoPlayerViewModel
    
    init(video: VideoResponse) {
        _viewModel = StateObject(wrappedValue: FullVideoPlayerViewModel(video: video))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            videoPlayer
            downloadStatusView
        }
        .navigationTitle(viewModel.video.title)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var videoPlayer: some View {
        if let player = viewModel.player {
            VideoPlayer(player: player)
                .onAppear { player.play() }
                .onDisappear { player.pause() }
                .ignoresSafeArea()
        } else {
            ProgressView()
                .frame(height: 300)
        }
    }
    
    @ViewBuilder
    private var downloadStatusView: some View {
        VStack(spacing: 16) {
            switch viewModel.downloadState {
            case .downloading:
                downloadingView
            case .completed(let url):
                completedView(url: url)
            case .failed(let error):
                failedView(error: error)
            case .idle:
                downloadButton
            }
        }
        .padding(.vertical)
    }
    
    private var downloadingView: some View {
        VStack {
            ProgressView(value: viewModel.downloadProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal)
            
            Text(String(format: NSLocalizedString("download_progress", comment: ""), Int(viewModel.downloadProgress * 100)))
                .font(.caption)
                .monospacedDigit()
        }
        .transition(.opacity)
    }
    
    private func completedView(url: URL) -> some View {
        VStack {
            Text(LocalizedStringKey("download_completed"))
            Text(String(format: NSLocalizedString("download_saved_as", comment: ""), url.lastPathComponent))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func failedView(error: Error) -> some View {
        VStack {
            downloadButton
            Text(String(format: NSLocalizedString("download_error", comment: ""), error.localizedDescription))
                .foregroundColor(.red)
        }
    }
    
    private var downloadButton: some View {
        Button(action: viewModel.downloadVideo) {
            Text(LocalizedStringKey("download_video"))
        }
    }
}
