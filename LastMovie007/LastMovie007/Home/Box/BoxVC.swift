//
//  BoxVC.swift
//  VancedPlayer
//
//  Created by VancedPlayer on 20/04/2023.
//

import UIKit
import BoxSDK
import AuthenticationServices

class BoxVC: BaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var background: GradientView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var tblListVideo: UITableView!
    @IBOutlet weak var lbTitle: UILabel!
    
    var files: [File] = [File]()
    var boxService = BoxService()
    var reloadVideo: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.showToast(message: "This is a Toast message.")
        let nib = UINib(nibName: "BoxCell", bundle: nil)
        tblListVideo.register(nib, forCellReuseIdentifier: "BoxCell")
        tblListVideo.delegate = self
        tblListVideo.dataSource = self
        
        boxService.awake()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showLoading()
        boxService.signIn { isSuccess in
            if isSuccess == true {
                self.btnLogin.setTitle("Logout", for: .normal)
                self.boxService.requestCurrentAccount { user in
                    DispatchQueue.main.async {
                        self.tblListVideo.reloadData()
                    }
                    self.lbTitle.text = user?.name
                }
                self.boxService.search(MediaEnum.video) { listFile, error in
                    self.files = listFile
                    DispatchQueue.main.async {
                        self.tblListVideo.reloadData()
                        self.hideLoading()
                    }
                }
            }
        }
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true){
            self.reloadVideo?()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BoxCell", for: indexPath) as? BoxCell else { return UITableViewCell() }
        
        let file = files[indexPath.row]
        cell.index = indexPath.row
        cell.setData(file: file, index: indexPath.row)
        cell.clickDownload = {
            self.selectCell(index: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectCell(index: indexPath.row)
    }
    
    @IBAction func actionLogout(_ sender: Any) {
        if (btnLogin.title(for: .normal) == "Logout") {
            boxService.signOut()
            files = [File]()
            tblListVideo.reloadData()
            btnLogin.setTitle("Login", for: .normal)
        } else {
            boxService.signIn { isSuccess in
                self.btnLogin.setTitle("Logout", for: .normal)
                self.boxService.requestCurrentAccount { user in
                    self.lbTitle.text = user?.name
                }
                self.boxService.search(MediaEnum.video) { listFile, error in
                    self.files = listFile
                    DispatchQueue.main.async {
                        self.tblListVideo.reloadData()
                        
                    }
                }
            }
        }
    }
    
    
    
    func selectCell(index: Int) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(files[index].name!)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            Toast.show(message: "This file has been downloaded !: \(self.files[index].name!)", on: self.view)
        } else {
            self.showLoading()
            boxService.download(files[index]) { progress in
                
            } completion: { status, urlString in
                if status == true {
                    //                    self.viewDownload.isHidden = true
                    Toast.show(message: "Download success!", on: self.view)
                    do {
                        let pathDownloadInDevice = self.files[index].name!
                        
                        print("Save file: \(pathDownloadInDevice)")
                        DispatchQueue.main.async {
                            self.tblListVideo.reloadData()
                            self.hideLoading()
                        }
                    } catch {
                        print("\(error)")
                    }
                } else {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        print("\(error)")
                    }
                    DispatchQueue.main.async {
                        self.hideLoading()
                        Toast.show(message: "Download Failed!", on: self.view)
                    }
                }
            }
        }
    }
    
    func selectMoreCell(index: Int) {
        
    }
    
}
