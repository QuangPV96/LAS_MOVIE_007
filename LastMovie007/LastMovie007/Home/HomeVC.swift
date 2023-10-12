//
//  HomeVC.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import UIKit
import Photos
import MediaPlayer
import AVKit

class HomeVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var buttonHideMenu: UIButton!
    @IBOutlet weak var viewPlayMini: UIView!
    @IBOutlet weak var tblListVideo: UITableView!
    
    var homeVideos: [Video] = []
    var boxVideo: [Video] = []
    var libraryVideo: [Video] = []
    var playerViewController: AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "HomeCell", bundle: nil)
        tblListVideo.register(nib, forCellReuseIdentifier: "HomeCell")
        tblListVideo.delegate = self
        tblListVideo.dataSource = self
        boxVideo = DatabaseManager.shared.getBoxVideos()
        checkAndRequestPermissions()
    }
    
    @IBAction func actionShowMenu(_ sender: Any) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.buttonHideMenu.isHidden = false
            self.buttonHideMenu.alpha = 1.0
            self.viewMenu.isHidden = false
            self.viewMenu.alpha = 1.0
        }, completion: nil)
        
    }
    
    @IBAction func actionSearch(_ sender: Any) {
        let searchVC = SearchVC();
        searchVC.modalPresentationStyle = .fullScreen
        self.present(searchVC, animated: true)
    }
    
    @IBAction func actionHideMenu(_ sender: Any) {
        self.hideMenu();
    }
    
    @IBAction func actionHistory(_ sender: Any) {
        self.hideMenu();
        let history = History();
        history.modalPresentationStyle = .fullScreen
        self.present(history, animated: true)
    }
    
    @IBAction func actionMyFavourite(_ sender: Any) {
        self.hideMenu();
        let history = MyFavouriteVC();
        history.modalPresentationStyle = .fullScreen
        self.present(history, animated: true)
    }
    
    @IBAction func actionAddBox(_ sender: Any) {
        let boxVC = BoxVC();
        boxVC.modalPresentationStyle = .fullScreen
        boxVC.reloadVideo  = {
            self.boxVideo = DatabaseManager.shared.getBoxVideos()
            self.homeVideos = self.boxVideo + self.libraryVideo
            self.tblListVideo.reloadData()
        }
        self.present(boxVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeVideos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as? HomeCell else { return UITableViewCell() }
        
        cell.index = indexPath.row
        let video = homeVideos[indexPath.row]
        
        if(video.url.contains("/var/mobile/")){
            cell.setData(video: video)
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
                        let videoURL = URL(fileURLWithPath: video.url)
                        
                        let documentsURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!,isDirectory: true )
                        let urlToMyPath = documentsURL.appendingPathComponent(videoURL.lastPathComponent.removingPercentEncoding!)!
                        
                        self?.performVideoSharing(urlToMyPath)
                    }else if(value == 2){
                        //add my favourite
                        DatabaseManager.shared.addVideoToFavourites(videoId: video.id, videoName: video.name, videoURL: video.url, videoDate: video.date, videoDuration: video.duration)
                    }else{
                        //delete
                        self!.deleteVideoDownloaded(video)
                    }
                }
                Utils.showBottomSheet(from: self, with: bottomSheetVC)
            }
        }else{
            if let videoAsset = Utils.fetchAsset(withLocalIdentifier: video.id) {
                // Hiển thị thông tin của PHAsset trong cell
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
                            self!.deleteVideo(asset: videoAsset)
                        }
                    }
                    Utils.showBottomSheet(from: self, with: bottomSheetVC)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = homeVideos[indexPath.row]
        if video.url.contains("/var/mobile/"){
            self.playVideoFromBox(video)
        }else{
            if let videoAsset = Utils.fetchAsset(withLocalIdentifier: video.id) {
                // Hiển thị thông tin của PHAsset trong cell
                self.playVideoFromPHAsset(videoAsset)
            }
        }
        
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.buttonHideMenu.isHidden = true
            self.buttonHideMenu.alpha = 0.0
            self.viewMenu.isHidden = true
            self.viewMenu.alpha = 0.0
        }, completion: nil)
    }
    
    func checkAndRequestPermissions() {
        // Kiểm tra quyền truy cập vào thư viện ảnh
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if photoAuthorizationStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized {
                    self?.fetchVideos()
                } else {
                    // Hiển thị thông báo cho người dùng rằng quyền truy cập cần được cấp
                }
            }
        } else if photoAuthorizationStatus == .authorized {
            fetchVideos()
        } else {
            // Hiển thị thông báo cho người dùng rằng quyền truy cập cần được cấp
        }
        
        // Kiểm tra quyền truy cập vào thư viện phương tiện (media library)
        let mediaAuthorizationStatus = MPMediaLibrary.authorizationStatus()
        if mediaAuthorizationStatus == .notDetermined {
            MPMediaLibrary.requestAuthorization { [weak self] status in
                if status == .authorized {
                    // Thực hiện xử lý liên quan đến thư viện phương tiện ở đây (nếu cần)
                } else {
                    // Hiển thị thông báo cho người dùng rằng quyền truy cập cần được cấp
                }
            }
        }
    }
    
    
    
    func fetchVideos()
    {
        DispatchQueue.main.async {
            self.showLoading()
        }
        DispatchQueue.global(qos: .background).async {
            // Đây là nơi bạn thực hiện việc tải danh sách video trong luồng nền
            
            var libraryVideo = [Video]()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let fetchResults = PHAsset.fetchAssets(with: .video, options: nil)
            fetchResults.enumerateObjects { object, _, _ in
                let localIdentifier = object.localIdentifier
                let assetName = Utils.getOriginalFilenameVideo(video: object)
                let assetURL = object.value(forKey: "filename") as? String ?? ""
                
                let formattedDate = dateFormatter.string(from: object.creationDate ?? Date())
                
                let video = Video(id: localIdentifier, name: localIdentifier, url: assetURL, date: formattedDate, duration: Utils.stringFromTimeInterval(interval: object.duration))
                libraryVideo.append(video)
            }
            
            // Sau khi hoàn thành việc tải danh sách video, bạn cần cập nhật giao diện trên luồng chính
            DispatchQueue.main.async {
                self.showLoading() // Hiển thị loading view trên luồng chính
                self.homeVideos = self.boxVideo + libraryVideo
                self.hideLoading() // Ẩn loading view trên luồng chính
                self.tblListVideo.reloadData()
            }
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
                    self.homeVideos.removeAll { $0.id == asset.localIdentifier}
                    self.tblListVideo.reloadData()
                    self.hideLoading()
                } else {
                    // Xoá thất bại, in ra lỗi
                    print("Lỗi khi xoá video: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func deleteVideoDownloaded(_ video: Video){
        do {
            let videoURL = URL(fileURLWithPath: video.url)
            
            let documentsURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!,isDirectory: true )
            
            let urlToMyPath = documentsURL.appendingPathComponent(videoURL.lastPathComponent.removingPercentEncoding!)!
            
            try FileManager.default.removeItem(at: urlToMyPath)
            self.boxVideo.removeAll { $0.id == video.id}
            self.homeVideos.removeAll { $0.id == video.id}
            DatabaseManager.shared.removeVideoFromBox(videoId: video.id)
            self.tblListVideo.reloadData()
        } catch {
            print("\(error)")
        }
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
