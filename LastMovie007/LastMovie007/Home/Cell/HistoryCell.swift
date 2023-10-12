//
//  HomeCell.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import UIKit
import Photos

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var viewParent: BorderView!
    @IBOutlet weak var viewSelect: UIView!
    @IBOutlet weak var imgSelect: UIImageView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbName: UILabel!
    
    var videoAsset: PHAsset?
    
    var index: Int!
    var isSelectedCell: Bool!
    var clickMore: (() -> Void)?
    var clickSelect: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    func setData(videoAsset: PHAsset, isShowSelect: Bool, isSelected: Bool) {
        // Lưu trữ đối tượng PHAsset
        isSelectedCell = isSelected;
        self.videoAsset = videoAsset
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        let formattedDate = dateFormatter.string(from: videoAsset.creationDate ?? Date())
        self.lbDate?.text = formattedDate
        self.lbTime.text = Utils.stringFromTimeInterval(interval: videoAsset.duration)
        
        // Load video thumbnail
        PHCachingImageManager.default().requestImage(for: videoAsset,
                                                     targetSize: CGSize(width: 100, height: 100),
                                                     contentMode: .aspectFill,
                                                     options: nil) { (photo, _) in
            
            self.imgThumb?.image = photo
            
        }
        self.lbName.text = Utils.getOriginalFilenameVideo(video: videoAsset)
        
        viewSelect.isHidden = !isShowSelect;
        if(isShowSelect){
            if(isSelected){
                imgSelect.image = UIImage.init(named: "ic_selected")
            }else{
                imgSelect.image = UIImage.init(named: "ic_unselect")
            }
        }
    }
    
    func setData(video: Video, isShowSelect: Bool, isSelected: Bool) {
        // Lưu trữ đối tượng PHAsset
        let videoURL = URL(string: video.url)
        
        if(video.url.contains("youtube.com")){
            imgThumb.image = UIImage.init(named: "bg_default")
            self.lbName.text = video.url;
        }else if(video.url.contains("/var/mobile/")){
            self.lbName.text = video.name;
            
            // Đường dẫn đến tệp video
            let videoURL = URL(fileURLWithPath: video.url)
            
            let documentsURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!,isDirectory: true )
            
            let urlToMyPath = documentsURL.appendingPathComponent(videoURL.lastPathComponent.removingPercentEncoding!)!
            self.imgThumb?.image = Utils.getThumbnailFrom(path: urlToMyPath)
            
        }else{
            if let videoURL = videoURL {
                AVAsset(url:videoURL).generateThumbnail { [weak self] (image) in
                    DispatchQueue.main.async {
                        guard let image = image else { return }
                        self?.imgThumb.image = image
                    }
                }
            }
            if let videoName = Utils.getVideoName(from: video.url) {
                self.lbName.text = videoName;
            } else {
                print("Không thể lấy tên video từ đường link.")
            }
        }
        
        self.lbDate?.text = video.date
        
        self.lbTime.text = video.date
        
        viewSelect.isHidden = !isShowSelect;
        if(isShowSelect){
            if(isSelected){
                imgSelect.image = UIImage.init(named: "ic_selected")
            }else{
                imgSelect.image = UIImage.init(named: "ic_unselect")
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func actionClick(_ sender: Any) {
        isSelectedCell = !isSelectedCell;
        self.clickSelect?(isSelectedCell);
        if(isSelectedCell){
            imgSelect.image = UIImage.init(named: "ic_selected")
        }else{
            imgSelect.image = UIImage.init(named: "ic_unselect")
        }
    }
    
    
    @IBAction func clickMore(_ sender: Any) {
        self.clickMore?()
    }
}
