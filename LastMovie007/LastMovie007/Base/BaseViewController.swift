//
//  BaseViewController.swift
//  LastMovie007
//
//  Created by Tran Cuong on 05/10/2023.
//

import UIKit
import Photos
import AVKit

class BaseViewController: UIViewController {
    var loadingView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func removeBlurView() {
        // Loại bỏ blurView
        for subview in view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
    
    func shareVideo(_ selectedVideo: PHAsset) {
        // Định cấu hình tùy chọn
        let options = PHVideoRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        
        // Sử dụng PHImageManager để lấy URL của video từ PHAsset
        PHImageManager.default().requestAVAsset(forVideo: selectedVideo, options: options) { avAsset, _, _ in
            if let avAsset = avAsset as? AVURLAsset {
                let videoURL = avAsset.url
                
                // Sao chép tệp video vào vị trí của ứng dụng
                if let appURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let destinationURL = appURL.appendingPathComponent("sharedVideo.mp4")
                    do {
                        try FileManager.default.copyItem(at: videoURL, to: destinationURL)
                        
                        // Chia sẻ tệp video đã sao chép
                        self.performVideoSharing(destinationURL)
                    } catch {
                        // Xử lý lỗi khi sao chép tệp
                    }
                }
            }
        }
    }
    
    
    func performVideoSharing(_ videoURL: URL) {
        // Tạo một URL chia sẻ cho video
        let shareURL = [videoURL]
        
        // Tạo UIActivityViewController để chia sẻ video
        let activityViewController = UIActivityViewController(activityItems: shareURL, applicationActivities: nil)
        
        // Đảm bảo rằng dialog chia sẻ hiển thị trên màn hình
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        DispatchQueue.main.async {
            // Mã liên quan đến giao diện người dùng, ví dụ: hiển thị dialog chia sẻ
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    func showLoading() {
        if loadingView == nil {
            loadingView = UIView(frame: view.bounds)
            loadingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = loadingView!.center
            activityIndicator.startAnimating()
            
            loadingView?.addSubview(activityIndicator)
            view.addSubview(loadingView!)
        }
    }
    
    
    // Hàm ẩn view loading
    func hideLoading() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    
}
