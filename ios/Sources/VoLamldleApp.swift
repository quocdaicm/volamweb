import SwiftUI
import WebKit
import AVFoundation

@main
struct VoLamIdleApp: App {
    init() {
        // Cho phép phát nhạc/âm thanh kể cả khi gạt công tắc im lặng
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
                .background(Color.black.ignoresSafeArea())
                .statusBarHidden(true)
        }
    }
}

struct GameView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        // Game dùng fetch() để nạp âm thanh từ file nội bộ -> cần mở quyền đọc file://
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = context.coordinator
        web.isOpaque = false
        web.backgroundColor = .black
        web.scrollView.backgroundColor = .black
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.scrollView.bounces = false
        context.coordinator.web = web
        context.coordinator.load()
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var web: WKWebView?

        func load() {
            guard let web = web,
                  let dir = Bundle.main.url(forResource: "Game", withExtension: nil) else { return }
            web.loadFileURL(dir.appendingPathComponent("index.html"), allowingReadAccessTo: dir)
        }

        // iOS có thể tự tắt tiến trình web khi thiếu RAM -> tải lại thay vì để màn hình trắng
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            load()
        }
    }
}
