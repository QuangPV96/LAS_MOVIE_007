//
//  BoxCell.swift
//  LastMovie007
//
//  Created by Tran Cuong on 04/10/2023.
//

import UIKit
import BoxSDK


class BoxCell: UITableViewCell {
    
    @IBOutlet weak var viewParent: BorderView!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var imgDownload: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    
    var index: Int!
    var clickDownload: (() -> Void)?
    let dateFormatter = DateFormatter()
    var boxService = BoxService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateFormatter.dateFormat = "dd MMM, yyyy"
        boxService.awake()
    }

    
    func setData(file: File, index: Int) {
        self.index = index
        self.lbName.text = file.name
        self.lbTime.text = String(format: "%@", dateFormatter.string(from: file.modifiedAt ?? Date()))
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(file.name!)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            imgDownload.image = UIImage(named: "ic_downloaded")
            imgThumb.tintColor = UIColor(hex: 0x545EFF)
        } else {
            imgDownload.image = UIImage(named: "ic_download")
        }
        boxService.getThumbnaiVideo(file){ image in
            self.imgThumb.image = image
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
