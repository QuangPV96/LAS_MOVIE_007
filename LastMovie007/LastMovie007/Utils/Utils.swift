//
//  Utils.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import Foundation
import UIKit
import Photos

class Utils {
    
    static func showAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func createGradientLayer(startColorHex: Int, endColorHex: Int, frame: CGRect) -> CAGradientLayer {
        // Tạo mã màu từ mã hex
        let startColor = UIColor(hex: startColorHex)
        let endColor = UIColor(hex: endColorHex)
        
        // Tạo gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        
        // Đặt màu cho gradient layer
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        // Chỉ định hướng của gradient (ở đây là từ trái qua phải)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        return gradientLayer
    }
    
    static func showBottomSheet(from fromVC: UIViewController, with dialog: UIViewController) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.alpha = 0.5
        blurView.frame = fromVC.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fromVC.view.addSubview(blurView)
        
        dialog.modalPresentationStyle = .custom
        fromVC.present(dialog, animated: true, completion: nil)
    }
    
    static func stringFromTimeInterval(interval: TimeInterval) -> String {
        let ti = NSInteger(interval)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
    
    static func getOriginalFilenameVideo(video: PHAsset)-> String {
        let assetResources = PHAssetResource.assetResources(for: video)
        var originalFilename = "";
        if let videoResource = assetResources.first {
            let videoName = videoResource.originalFilename
            originalFilename = videoName
        }
        return originalFilename;
    }
    
    static func fetchAsset(withLocalIdentifier localIdentifier: String) -> PHAsset? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", localIdentifier)
        let result = PHAsset.fetchAssets(with: fetchOptions)
        return result.firstObject
    }
    
    static func extractYouTubeVideoID(from url: String) -> String? {
        if let urlComponents = URLComponents(string: url) {
            if let queryItems = urlComponents.queryItems {
                for queryItem in queryItems {
                    if queryItem.name == "v" {
                        return queryItem.value
                    }
                }
            }
        }
        return nil
    }
    
    static func getVideoName(from videoURL: String) -> String? {
        if let url = URL(string: videoURL) {
            // Lấy phần cuối cùng của đường link (phần cuối cùng sau dấu '/')
            let videoName = url.lastPathComponent
            
            // Lấy phần trước dấu '.' để loại bỏ phần mở rộng (ví dụ: ".m4v")
            if let dotRange = videoName.range(of: ".") {
                let nameWithoutExtension = videoName[..<dotRange.lowerBound]
                return String(nameWithoutExtension)
            }
        }
        return nil
    }
    
    static func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 5), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return UIImage.init(named: "bg_default")
            
        }
    }
    
}
