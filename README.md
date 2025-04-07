# 📹 Video Streaming App

This iOS application, built with SwiftUI, demonstrates fetching and streaming videos with a focus on robust buffering and download management. It follows the Model-View-ViewModel (MVVM) architecture and utilizes modern iOS development practices.

## 🏗️ Architectural Decisions

The application adopts the **Model-View-ViewModel (MVVM)** architectural pattern to achieve a clear separation of concerns:

* **Models:** Plain Swift structs (`VideoResponse`) represent the data fetched from the API. They are responsible for holding the application's data.
* **ViewModels:** (`VideoListViewModel`, `FullVideoPlayerViewModel`) act as intermediaries between the Views and the Models/Services. They contain the presentation logic, fetch and process data, and expose observable properties that the Views can bind to. This separation makes the Views lean and focused on display, while the ViewModels handle the business logic and state management.
* **Views:** SwiftUI components (`ContentView`, `VideoFeedContentView`, `VideoCard`, `VideoPlayerView`) are responsible for rendering the user interface based on the state provided by the ViewModels. They observe changes in the ViewModels and update accordingly.
* **Services:** (`NetworkServiceImpl`, `FileStorageManagerImpl`, `VideoServiceImpl`) encapsulate specific business functionalities, such as network requests, file system operations, and video-related logic. This promotes reusability and testability.

**Key Architectural Principles:**

* **Separation of Concerns:** Each component has a specific responsibility, making the codebase more organized and easier to understand.
* **Testability:** The separation of logic into ViewModels and Services makes it easier to write unit tests for these components without relying on the UI.
* **Maintainability:** Changes in one part of the application are less likely to affect other parts due to the decoupled nature of the architecture.
* **Reactive Programming (via Combine):** Combine is used for observing changes in the `AVPlayer`'s status, allowing the UI to react to playback events.
* **Swift Concurrency (`async/await`):** Modern concurrency features are used for handling asynchronous operations like network requests and file downloads, improving code readability and managing background tasks effectively.
* **Protocol-Oriented Design:** Protocols define clear interfaces between components, enabling dependency injection and making it easier to swap implementations if needed.

## 💾 Buffering and Download Handling Design

The application implements buffering and download handling with the following considerations:

**Buffering (Video Playback):**

* **`AVPlayer`'s Built-in Buffering:** The core of the buffering mechanism relies on `AVPlayer`'s inherent capabilities. When a remote video URL is provided, `AVPlayer` automatically handles buffering the video data before and during playback.
* **`playerState` Management:** The `FullVideoPlayerViewModel` tracks the `AVPlayer`'s status using Combine (`publisher(for: \.status)`). The `playerState` (`ViewStateEnum<AVPlayer>`) reflects whether the player is ready to play, loading, or has encountered an error. This allows the UI to provide feedback to the user about the buffering state (e.g., displaying a loading indicator).
* **Pre-buffering (Implicit):** `AVPlayer` typically pre-buffers a certain amount of data to ensure smooth playback. The extent of pre-buffering depends on the network conditions and the player's internal algorithms.
* **Error Handling:** If buffering issues lead to playback failures (e.g., network interruptions), the `playerState` will transition to the `.error` case, and an appropriate error message will be displayed to the user.

**Download Handling:**

* **`VideoServiceImpl.downloadVideo(from:onProgress:)`:** This function in the `VideoServiceImpl` is responsible for downloading video files.
* **`URLSession.bytes(from:progressHandler:)` (within `NetworkClientImpl`):** This method efficiently downloads the file data in chunks, providing an asynchronous sequence of bytes.
* **Progress Tracking (`onProgress` Closure):** The `downloadVideo` function takes a closure (`onProgress`) that is called periodically during the download process. The `NetworkClientImpl` throttles these progress updates to avoid flooding the UI thread.
* **Main Actor Updates:** The progress updates received in the `onProgress` closure (which might occur on a background thread) are dispatched to the main actor using `Task { @MainActor in ... }` to safely update the `@Published` `downloadProgress` property in the `FullVideoPlayerViewModel`. This ensures that UI updates are thread-safe.
* **Local Storage (`FileStorageManagerImpl`):** Downloaded video data is saved to the app's Documents directory using the `FileStorageManagerImpl`. The `getLocalURL(forRemoteURL:)` function determines the local file path based on the remote URL.
* **Existing Download Check:** When the `FullVideoPlayerViewModel` is initialized, it checks if the video has already been downloaded locally using `checkExistingDownload()`. If so, it sets the `downloadState` to `.completed` and prioritizes the local file for playback.
* **Download State Management (`downloadState`):** The `downloadState` (`DownloadStateEnum`) in `FullVideoPlayerViewModel` tracks the current state of the download operation (idle, downloading, completed with the local URL, failed with an error).
* **Error Handling:** If the download fails at any stage (e.g., network error, file system error), the `downloadState` transitions to `.failed` with the corresponding error.
* **File Removal:** The `FileStorageManagerImpl` provides a `removeFile(at:)` function to delete locally stored videos if needed.

## 🛠️ How to Build and Run the App

1.  **Prerequisites:**
    * Xcode (latest recommended version) installed on your macOS.
    * iOS 15.0 or later deployment target (as the project uses `async/await` and other modern Swift features).

2.  **Clone the Repository:**
    Open your terminal and navigate to the directory where you want to clone the project. Then, run the following command:
    ```bash
    git clone [repository_url]
    cd [project_directory]
    ```
    (Replace `[repository_url]` with the actual URL of your project's Git repository and `[project_directory]` with the name of the cloned folder.)

3.  **Open the Project in Xcode:**
    Locate the `YourProjectName.xcodeproj` file (or `.xcworkspace` if you are using CocoaPods or Swift Package Manager for dependency management, although this project as provided doesn't explicitly show external dependencies) in the cloned directory and open it with Xcode.

4.  **Select a Target Device/Simulator:**
    In Xcode, select a target device (a physical iOS device connected to your Mac or an iOS simulator) from the scheme menu (usually located at the top left of the Xcode window, next to the "Run" and "Stop" buttons).

5.  **Build and Run:**
    Press the "Run" button (Cmd+R) or navigate to `Product` > `Run` in the Xcode menu. Xcode will build the project and launch the application on your selected device or simulator.

6.  **Interact with the App:**
    * The app will initially display a list of video titles fetched from the remote API.
    * Tap on a video card to navigate to the video player screen.
    * On the video player screen, you should see the video (it will start buffering).
    * You wi    ll also find a button (or similar UI element) to initiate the download of the video. Tapping this will start the download, and a progress indicator will be displayed.
    * Once the download is complete, the app will prioritize playing the locally stored video in subsequent sessions.

**Note:** Ensure your development machine has a stable internet connection to fetch the video list and download videos.

### ⚠️ App Transport Security Configuration

> Location: `Info.plist`

This project includes a **temporary App Transport Security (ATS) exception** for the domain `example.com`, as shown below:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>example.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.1</string>
        </dict>
    </dict>
</dict>

Made with ❤️ in Brazil.
