//
//  MyFavouriteVC.swift
//  LastMovie007
//
//  Created by Tran Cuong on 05/10/2023.
//

import UIKit
import Photos
import AVKit

class MyFavouriteVC: UIViewController ,UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tblListVideo: UITableView!
    @IBOutlet weak var viewPlayMini: UIView!
    var favouriteVideos: [Video] = []
    var playerViewController: AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favouriteVideos = DatabaseManager.shared.getFavouriteVideos()
        
        let nib = UINib(nibName: "FavouriteCell", bundle: nil)
        tblListVideo.register(nib, forCellReuseIdentifier: "FavouriteCell")
        tblListVideo.delegate = self
        tblListVideo.dataSource = self
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteVideos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteCell", for: indexPath) as? FavouriteCell else { return UITableViewCell() }
        
        let video = favouriteVideos[indexPath.row]
        cell.index = indexPath.row
        
        if(video.id.contains("http")){
            cell.setData(video: video)
        }else if(video.id.contains("/var/mobile/")){
            cell.setData(video: video)
        }else{
            if let asset = Utils.fetchAsset(withLocalIdentifier: video.id) {
                // Hiển thị thông tin của PHAsset trong cell
                cell.setData(videoAsset: asset)
                
                cell.clickRemove = {
                    DatabaseManager.shared.removeVideoFromFavourites(videoId: video.id)
                    self.favouriteVideos.removeAll { $0.id == video.id}
                    self.tblListVideo.reloadData()
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = favouriteVideos[indexPath.row]
        if(video.id.contains("http")){
            let play = PlayStreamVC();
            play.linkUrl = video.url;
            play.playvideoCallback = { [weak self] player in
                print("play mini")
                self?.playMini(player: player)
            }
            play.videoId = video.id
            play.modalPresentationStyle = .fullScreen
            self.present(play, animated: true)
        }else if(video.id.contains("/var/mobile/")){
            self.playVideoFromBox(video)
        }else{
            if let asset = Utils.fetchAsset(withLocalIdentifier: video.id) {
                self.playVideoFromPHAsset(asset)
            }
        }
        
    }
    
    func playVideoFromPHAsset(_ asset: PHAsset) {
        let play = PlayStreamVC();
        play.videoLocal = asset;
        play.videoId = asset.localIdentifier
        play.modalPresentationStyle = .fullScreen
        play.playvideoCallback = { [weak self] player in
            print("play mini")
            self?.playMini(player: player)
        }
        self.present(play, animated: true)
    }
    
    func playMini(player: AVPlayer){
        viewPlayMini.isHidden = false;
        playerViewController = AVPlayerViewController()
        playerViewController.player = player

        // (Tùy chọn) Tùy chỉnh các thuộc tính của trình phát video
        playerViewController.showsPlaybackControls = true

        // Hiển thị trình phát video
        self.addChild(playerViewController)
        viewPlayMini.addSubview(playerViewController.view)
        playerViewController.view.frame = CGRect(x: 0, y: 0, width: viewPlayMini.frame.width, height: viewPlayMini.frame.height)

        player.play()
        
        let closeButton = UIButton(type: .system)
        let closeImage = UIImage(named: "ic_close")
        closeButton.setImage(closeImage, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        viewPlayMini.addSubview(closeButton)
    }
    
    @objc func closeButtonTapped() {
        // Ẩn hoặc loại bỏ AVPlayerViewController và dừng phát video
        playerViewController.player?.pause()
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()
        viewPlayMini.isHidden = true;
    }
    
    func playVideoFromBox(_ video: Video) {
        DatabaseManager.shared.addVideoToHistory(videoId: video.id, videoName: video.name, videoURL: video.url, videoDate: video.date, videoDuration: video.duration)
        let play = PlayStreamVC();
        play.videoId = video.id
        play.linkUrl = video.url;
        play.videoName = video.name
        play.modalPresentationStyle = .fullScreen
        play.playvideoCallback = { [weak self] player in
            print("play mini")
            self?.playMini(player: player)
        }
        self.present(play, animated: true)
    }
}
