//
//  History.swift
//  LastMovie007
//
//  Created by Tran Cuong on 05/10/2023.
//

import UIKit
import Photos
import AVKit

class History: BaseViewController ,UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var lbCountDelete: UILabel!
    @IBOutlet weak var tblListVideo: UITableView!
    @IBOutlet weak var viewNumber: UIView!
    @IBOutlet weak var viewDelete: GradientView!
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var viewPlayMini: UIView!
    
    var historyVideos: [Video] = []
    var historyVideosSelected: [Video] = []
    var isSelect: Bool = false;
    var playerViewController: AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyVideos = DatabaseManager.shared.getHistoryVideos()
        
        let nib = UINib(nibName: "HistoryCell", bundle: nil)
        tblListVideo.register(nib, forCellReuseIdentifier: "HistoryCell")
        tblListVideo.delegate = self
        tblListVideo.dataSource = self
        
        viewNumber.layer.cornerRadius = 15
        viewNumber.layer.borderWidth = 3.75;
        viewNumber.layer.borderColor = UIColor.white.cgColor
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionSelect(_ sender: Any) {
        isSelect = !isSelect;
        tblListVideo.reloadData()
    }
    
    @IBAction func actionDelete(_ sender: Any) {
        if(historyVideosSelected.count > 0){
            DatabaseManager.shared.removeVideosFromHistory(type: VideoListType.history, videoList: historyVideosSelected)
            
            for check in historyVideosSelected{
                historyVideos.removeAll { $0.id == check.id}
            }
            tblListVideo.reloadData()
            historyVideosSelected.removeAll()
            viewNumber.isHidden = true;
            viewDelete.isHidden = false;
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyVideos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else { return UITableViewCell() }
        
        let video = historyVideos[indexPath.row]
        cell.index = indexPath.row
        
        var select: Bool = false;
        for check in historyVideosSelected{
            if(video.id == check.id){
                select = true;
                break
            }
        }
        
        if(video.id.contains("http")){
            cell.setData(video: video, isShowSelect: isSelect, isSelected: select)
            
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
                        let activityViewController = UIActivityViewController(activityItems: [video.id], applicationActivities: nil)
                        self?.present(activityViewController, animated: true, completion: nil)
                    }else if(value == 2){
                        //add my favourite
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd MMM, yyyy"
                        let strDate = dateFormatter.string(from: Date())
                        DatabaseManager.shared.addVideoToFavourites(videoId: video.id, videoName: strDate, videoURL: video.id, videoDate:  video.date, videoDuration: video.duration)
                    }else{
                        //delete
                        self?.removeFromList(video: video)
                    }
                }
                Utils.showBottomSheet(from: self, with: bottomSheetVC)
            }
        }else if(video.id.contains("/var/mobile/")){
            cell.setData(video: video, isShowSelect: isSelect, isSelected: select)
            
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
                        let activityViewController = UIActivityViewController(activityItems: [video.id], applicationActivities: nil)
                        self?.present(activityViewController, animated: true, completion: nil)
                    }else if(value == 2){
                        //add my favourite
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd MMM, yyyy"
                        let strDate = dateFormatter.string(from: Date())
                        DatabaseManager.shared.addVideoToFavourites(videoId: video.id, videoName: strDate, videoURL: video.id, videoDate:  video.date, videoDuration: video.duration)
                    }else{
                        //delete
                        self?.removeFromList(video: video)
                    }
                }
                Utils.showBottomSheet(from: self, with: bottomSheetVC)
            }
        }else{
            if let asset = Utils.fetchAsset(withLocalIdentifier: video.id) {
                // Hiển thị thông tin của PHAsset trong cell

                cell.setData(videoAsset: asset, isShowSelect: isSelect, isSelected: select)
                cell.clickSelect = {[weak self] value in
                    self?.addVideoSelected(video: video, isRemove: !value)
                }
                
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
                            self?.shareVideo(asset)
                        }else if(value == 2){
                            //add my favourite
                            DatabaseManager.shared.addVideo(type: VideoListType.favourite, videoAsset: asset)
                        }else{
                            //delete
                            self?.deleteVideo(asset: asset)
                        }
                    }
                    Utils.showBottomSheet(from: self, with: bottomSheetVC)
                }
            }
        }
        
        if let asset = Utils.fetchAsset(withLocalIdentifier: video.id) {
            // Hiển thị thông tin của PHAsset trong cell
            var select: Bool = false;
            for check in historyVideosSelected{
                if(video.id == check.id){
                    select = true;
                    break
                }
            }
            cell.setData(videoAsset: asset, isShowSelect: isSelect, isSelected: select)
            
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
                        self?.shareVideo(asset)
                    }else if(value == 2){
                        //add my favourite
                        DatabaseManager.shared.addVideo(type: VideoListType.favourite, videoAsset: asset)
                    }else{
                        //delete
                        self?.deleteVideo(asset: asset)
                    }
                }
                Utils.showBottomSheet(from: self, with: bottomSheetVC)
            }
        }
        
        cell.clickSelect = {[weak self] value in
            self?.addVideoSelected(video: video, isRemove: !value)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = historyVideos[indexPath.row]
        if(video.id.contains("http")){
            let play = PlayStreamVC();
            play.videoId = video.id
            play.linkUrl = video.url;
            play.playvideoCallback = { [weak self] player in
                print("play mini")
                self?.playMini(player: player)
            }
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
    
    func addVideoSelected(video: Video, isRemove: Bool){
        var add: Bool = true;
        if(isRemove){
            historyVideosSelected.removeAll { $0.id == video.id}
        }else{
            for check in historyVideosSelected{
                if(video.id == check.id){
                    add = false;
                    break
                }
            }
            if(add){
                historyVideosSelected.append(video)
            }
        }
        if(historyVideosSelected.count > 0){
            viewNumber.isHidden = false
            lbCount.text = "\(historyVideosSelected.count)"
            lbCountDelete.text = "Delete \(historyVideosSelected.count) video"
            viewDelete.isHidden = false;
        }else{
            viewNumber.isHidden = true;
            viewDelete.isHidden = false;
        }
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
                    self.historyVideos.removeAll { $0.id == asset.localIdentifier}
                    self.tblListVideo.reloadData()
                    self.hideLoading()
                } else {
                    // Xoá thất bại, in ra lỗi
                    print("Lỗi khi xoá video: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func removeFromList(video: Video){
        DatabaseManager.shared.removeVideosFromHistory(type: VideoListType.history, videoList: [video])
        historyVideos.removeAll { $0.id == video.id}
        tblListVideo.reloadData()
    }
    
    func playVideoFromPHAsset(_ asset: PHAsset) {
        let play = PlayStreamVC();
        play.videoId = asset.localIdentifier
        play.videoLocal = asset;
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
        play.linkUrl = video.url;
        play.videoName = video.name
        play.videoId = video.id
        play.modalPresentationStyle = .fullScreen
        play.playvideoCallback = { [weak self] player in
            print("play mini")
            self?.playMini(player: player)
        }
        self.present(play, animated: true)
    }
}
