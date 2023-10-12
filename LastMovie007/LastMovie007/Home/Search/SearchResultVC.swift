//
//  SearchResultVC.swift
//  LastMovie007
//
//  Created by Tran Cuong on 05/10/2023.
//

import UIKit
import Photos
import AVKit

class SearchResultVC: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tblListVideo: UITableView!
    @IBOutlet weak var viewPlayMini: UIView!
    
    var playerViewController: AVPlayerViewController!
    var searchResults: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "HomeCell", bundle: nil)
        tblListVideo.register(nib, forCellReuseIdentifier: "HomeCell")
        tblListVideo.delegate = self
        tblListVideo.dataSource = self
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as? HomeCell else { return UITableViewCell() }
        
        cell.index = indexPath.row
        let videoAsset = searchResults[indexPath.row]
        cell.setData(videoAsset: videoAsset)
        cell.clickMore = {
            let bottomSheetVC = HomeMoreDialog()
            bottomSheetVC.dismissCallback = { [weak self] in
                self?.removeBlurView()
            }
            bottomSheetVC.optionSelectedCallback = { [weak self] value in
                // Xử lý giá trị integer tại đây
                print("Received integer value: \(value)")
                if(value == 1){
                    //share
                    // Kiểm tra xem người dùng đã chọn video nào chưa
                    self?.shareVideo(videoAsset)
                }else if(value == 2){
                    //add my favourite
                    DatabaseManager.shared.addVideo(type: VideoListType.favourite, videoAsset: videoAsset)
                }else{
                    //delete
                    self?.deleteVideo(asset: videoAsset)
                }
            }
            Utils.showBottomSheet(from: self, with: bottomSheetVC)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoAsset = searchResults[indexPath.row]
        self.playVideoFromPHAsset(videoAsset)
    }
    
    func playVideoFromPHAsset(_ asset: PHAsset) {
        DatabaseManager.shared.addVideo(type: VideoListType.history, videoAsset: asset)
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
    
    func deleteVideo(asset: PHAsset) {
        showLoading()
        PHPhotoLibrary.shared().performChanges({
            // Tạo một mảng PHAsset để truyền vào deleteAssets
            let assetsToDelete = [asset] as NSFastEnumeration
            PHAssetChangeRequest.deleteAssets(assetsToDelete)
        }) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    // Xoá thành công
                    print("Xoá video thành công")
                    self.searchResults.removeAll { $0.localIdentifier == asset.localIdentifier}
                    self.tblListVideo.reloadData()
                    self.hideLoading()
                } else {
                    // Xoá thất bại, in ra lỗi
                    print("Lỗi khi xoá video: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
}
