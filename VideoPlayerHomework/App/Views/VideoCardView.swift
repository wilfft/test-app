import SwiftUI

struct VideoCard: View {
    var video: VideoResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                Text(video.title)
                    .font(.headline)
                    .lineLimit(2)
                    .shadow(radius: 10)
                    .multilineTextAlignment(.leading)
                    .padding()
          
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VideoCard(video: .init(
        id: "1",
        title: "Big Buck Bunny - Um clássico animado de código aberto",
        videoUrl: "https://example.com/video.mp4"
    ))
    .frame(width: 300)
    .padding()
}
