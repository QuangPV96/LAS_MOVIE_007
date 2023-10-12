//
//  HomeCell.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import UIKit
import Photos
import BoxSDK

class HomeCell: UITableViewCell {
    
    @IBOutlet weak var viewParent: BorderView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbName: UILabel!
    
    var videoAsset: PHAsset?
    
    var index: Int!
    var clickMore: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    func setData(videoAsset: PHAsset) {
        // Lưu trữ đối tượng PHAsset
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
    }
    
    func setData(video: Video) {
        self.lbName.text = video.name;
        
        // Đường dẫn đến tệp video
        let videoURL = URL(fileURLWithPath: video.url)
        
        let documentsURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!,isDirectory: true )
        
        let urlToMyPath = documentsURL.appendingPathComponent(videoURL.lastPathComponent.removingPercentEncoding!)!
        self.imgThumb?.image = Utils.getThumbnailFrom(path: urlToMyPath)
        
        self.lbDate.text = video.date;
        
        let asset = AVURLAsset(url: urlToMyPath , options: nil)

        let durationInSeconds = CMTimeGetSeconds(asset.duration) // Lấy duration từ AVAsset
        let hours = Int(durationInSeconds) / 3600
        let minutes = Int(durationInSeconds) / 60 % 60
        let seconds = Int(durationInSeconds) % 60

        let formattedDuration = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        self.lbTime.text = formattedDuration;

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func clickMore(_ sender: Any) {
        self.clickMore?()
    }
}
