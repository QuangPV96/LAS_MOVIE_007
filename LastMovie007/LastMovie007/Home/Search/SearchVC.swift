//
//  SearchVC.swift
//  LastMovie007
//
//  Created by Tran Cuong on 05/10/2023.
//

import UIKit
import Photos

class SearchVC: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfSearch: UITextField!
    var searchResults: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfSearch.delegate = self
    }
    
    
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let searchText = textField.text, !searchText.isEmpty {
            showLoading()
            DispatchQueue.global(qos: .background).async { [weak self] in
                let searchResults = self?.searchVideos(withName: searchText) ?? []
                
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.showSearchResults(searchResults)
                }
            }
        } else {
            searchResults.removeAll()
        }
        
        return true
    }
    
    func searchVideos(withName name: String) -> [PHAsset] {
        var results: [PHAsset] = []
        let fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
        fetchResults.enumerateObjects({ (object, count, stop) in
            let assetName = Utils.getOriginalFilenameVideo(video: object)
            if assetName.lowercased().contains(name.lowercased()) {
                results.append(object)
            }
        })
        return results
    }
    
    func showSearchResults(_ searchResults: [PHAsset]) {
        let searchResult = SearchResultVC()
        searchResult.modalPresentationStyle = .fullScreen
        searchResult.searchResults = searchResults
        self.present(searchResult, animated: true)
    }
}
