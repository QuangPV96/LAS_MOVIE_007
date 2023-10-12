//
//  PlayStreamVC.swift
//  LastMovie007
//
//  Created by Tran Cuong on 05/10/2023.
//

import UIKit
import AVFoundation
import AVKit
import youtube_ios_player_helper_swift
import Photos

class PlayStreamVC: UIViewController, YTPlayerViewDelegate{
    @IBOutlet weak var lbLink: UILabel!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var viewAV: UIView!
    @IBOutlet weak var ytPlayer: YTPlayerView!
    
    var linkUrl: String = ""
    var islike: Bool = false;
    var player: AVPlayer!
    var playerViewController: AVPlayerViewController!
    var videoLocal: PHAsset?
    var playvideoCallback: ((AVPlayer) -> Void)?
    var videoDownload: String?
    var videoName: String?
    var videoId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DatabaseManager.shared.videoExistsInFavourites(videoId: videoId ?? "") {
            imgLike.image = UIImage.init(named: "ic_heart_2")
            islike = true;
        } else {
            // Xử lý khi video đã tồn tại
            imgLike.image = UIImage.init(named: "ic_heart")
        }
        
        if(linkUrl.contains("http")){
            lbLink.text = linkUrl;
            
            if(linkUrl.contains("youtube")){
                ytPlayer.isHidden = false;
                ytPlayer.load(videoId: Utils.extractYouTubeVideoID(from: linkUrl) ?? "")
                ytPlayer.delegate = self
                ytPlayer.playVideo()
            }else{
                ytPlayer.isHidden = true;
                // Đường link video bạn muốn phát
                let videoURL = URL(string: linkUrl)
                
                if let videoURL = videoURL {
                    player = AVPlayer(url: videoURL)
                    playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    
                    // (Tùy chọn) Tùy chỉnh các thuộc tính của trình phát video
                    playerViewController.showsPlaybackControls = true
                    
                    // Hiển thị trình phát video
                    self.addChild(playerViewController)
                    self.view.addSubview(playerViewController.view)
                    playerViewController.view.frame = self.ytPlayer.frame
                    
                    player.play()
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let strDate = dateFormatter.string(from: Date())
            DatabaseManager.shared.addVideoToHistory(videoId: linkUrl, videoName: linkUrl, videoURL: linkUrl, videoDate:  strDate, videoDuration: "")
        }else if(linkUrl.contains("/var/mobile/Containers/Data/Application")){
            lbLink.text = videoName;
            let videoURL = URL(string: linkUrl)
            if let videoURL = videoURL {
                let documentsURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!,isDirectory: true )
                
                let urlToMyPath = documentsURL.appendingPathComponent(videoURL.lastPathComponent.removingPercentEncoding!)!
                
                player = AVPlayer(url: urlToMyPath)
                playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                // (Tùy chọn) Tùy chỉnh các thuộc tính của trình phát video
                playerViewController.showsPlaybackControls = true
                
                // Hiển thị trình phát video
                self.addChild(playerViewController)
                self.view.addSubview(playerViewController.view)
                playerViewController.view.frame = self.ytPlayer.frame
                
                player.play()
            }
        }else{
            if let videoLocal = videoLocal {
                lbLink.text = Utils.getOriginalFilenameVideo(video: videoLocal);
                
                PHCachingImageManager.default().requestAVAsset(forVideo: videoLocal, options: nil) { [weak self] (video, _, _) in
                    if let video = video
                    {
                        DispatchQueue.main.async {
                            self?.playVideo(video)
                        }
                    }
                }
                
                
            }
        }
        
        
    }
    
    @IBAction func actionFavourite(_ sender: Any) {
        islike = !islike;
        if(islike){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let strDate = dateFormatter.string(from: Date())
            DatabaseManager.shared.addVideoToFavourites(videoId: linkUrl, videoName: lbLink.text ?? linkUrl, videoURL: linkUrl, videoDate:  strDate, videoDuration: "")
            imgLike.image = UIImage.init(named: "ic_heart_2")
        }else{
            DatabaseManager.shared.removeVideoFromFavourites(videoId: linkUrl);
            imgLike.image = UIImage.init(named: "ic_heart")
        }
        
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        if let player = self.player {
            dismiss(animated: true){
                self.playvideoCallback?(player)
            }
        }else{
            dismiss(animated: true)
        }
    }
    
    func playVideo(_ video: AVAsset)
    {
        let playerItem = AVPlayerItem(asset: video)
        player = AVPlayer(playerItem: playerItem)
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // (Tùy chọn) Tùy chỉnh các thuộc tính của trình phát video
        playerViewController.showsPlaybackControls = true
        
        // Hiển thị trình phát video
        self.addChild(playerViewController)
        self.view.addSubview(playerViewController.view)

        playerViewController.view.frame = self.ytPlayer.frame
        
        player.play()
    }

    
}
