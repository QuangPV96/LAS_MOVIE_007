//
//  BoxService.swift
//  OfflineMusic
//
//  Created by VancedPlayer on 13/01/2023.
//

import UIKit
import BoxSDK
import AuthenticationServices

enum BoxError: Error {
    case NotAuthorized
    case OffsetNotExists
}

enum MediaEnum {
    case video
    case audio
}

class BoxService: NSObject {
    private var sdk: BoxSDK!
    private var client: BoxClient?
    private var window: UIWindow?
    
    private var page: Int = 0
    private var more: Bool = false
    
    var authorized: Bool {
        return client != nil
    }
    
    // current user logged
    var user: User?
    
    static let shared = BoxService()
    
    override init() {
    }
    
    func awake() {
        sdk = BoxSDK(clientId: Constants.clientId, clientSecret: Constants.clientSecret)
        KeychainTokenStore().read { (result) in
            switch result {
            case .success(_):
                self.signIn { success in
                    self.requestCurrentAccount { (user) in }
                }
            case let .failure(error):
                print("Error read keychain BoxSdk: \(error.localizedDescription)")
            }
        }
    }
    
    func requestCurrentAccount(_ completion: @escaping (_ user: User?) -> Void) {
        guard let cl = client else {
            self.user = nil
            completion(nil)
            return
        }
        cl.users.getCurrent(fields: ["name", "login"]) { (result: Result<User, BoxSDKError>) in
            guard case let .success(user) = result else {
                DispatchQueue.main.async {
                    self.user = nil
                }
                return
            }
            DispatchQueue.main.async {
                self.user = user
                completion(user)
            }
        }
    }
    
    func getThumbnaiVideo(_ fileItem: File?, _ completion: @escaping (_ image: UIImage?) -> Void) {
        guard let fileItem = fileItem, let cl = client else {
            DispatchQueue.main.async {
                completion(UIImage.init(named: "bg_default"))
            }
            return
        }
        cl.files.getThumbnail(forFile: fileItem.id, extension: .png) { (result: Result<Data, BoxSDKError>) in
            guard case let .success(thumbnailData) = result else {
                print("BoxSDK: Error getting file thumbnail")
                DispatchQueue.main.async {
                    completion(UIImage.init(named: "bg_default"))
                }
                return
            }
            
            let thumbnailImage = UIImage(data: thumbnailData)
            DispatchQueue.main.async {
                completion(thumbnailImage)
            }
        }
    }
    
    
    func signIn(_ completion: @escaping (_ success: Bool) -> Void) {
        if #available(iOS 13, *) {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context:self) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.client = client
                case let .failure(error):
                    self?.client = nil
                    print("error in getOAuth2Client: \(error)")
                }
                DispatchQueue.main.async {
                    completion(self?.client != nil)
                }
            }
        } else {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore()) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.client = client
                case let .failure(error):
                    self?.client = nil
                    print("error in getOAuth2Client: \(error)")
                }
                DispatchQueue.main.async {
                    completion(self?.client != nil)
                }
            }
        }
    }
    
    func signOut() {
        client = nil
        user = nil
        KeychainTokenStore().clear { (result) in
            switch result {
            case .success(): break
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    func search(_ media: MediaEnum, completion: @escaping (_ files: [File], _ error: Error?) -> Void) {
        guard let cl = client else {
            completion([], BoxError.NotAuthorized)
            return
        }
        var q = ""
        
        switch media {
        case .video:
            q = "*.mp4 OR *.mov OR *.mpeg"
        case .audio:
            q = "*.mp3 OR *.m4a OR *.wav"
        }
        
        // only get max 200 items
        let iterator = cl.search.query(query: q, itemType: .file, limit: 200)
        
        iterator.next { results in
            switch results {
            case let .success(page):
                var result: [File] = []
                
                for item in page.entries {
                    switch item {
                    case let .file(file):
                        result.append(file)
                    default: break
                    }
                }
                
                completion(result, nil)
                
            case let .failure(err):
                completion([], err.error)
                print(err)
            }
        }
    }
    
    func download(_ fileItem: File?, progressBlock: @escaping (Progress) -> Void, completion: @escaping ((Bool, String) -> Void)) {
        guard let fileItem = fileItem, let cl = client, let name = fileItem.name else {
            completion(false, "")
            return
        }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsURL.appendingPathComponent(name)
        
        cl.files.download(fileId: fileItem.id, destinationURL: url, version: nil, progress: progressBlock) { (result: Result<Void, BoxSDKError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(true, name)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd MMM, yyyy"
                    let strTime = String(format: "%@", formatter.string(from: fileItem.createdAt ?? Date()))
                    DatabaseManager.shared.addVideoToBox(videoId: "\(url)", videoName: name, videoURL: "\(url)", videoDate:  strTime, videoDuration:  "")
                    print("File downloaded successfully")
                case .failure(let failure):
                    print("Error downloading file: \(failure.localizedDescription)")
                    completion(false, "")
                }
            }
        }
    }
    
    func getFileEmbedLink(_ fileItem: File?, _ completion: @escaping (_ image: String?) -> Void) {
        guard let fileItem = fileItem, let cl = client else {
            DispatchQueue.main.async {
                completion("")
            }
            return
        }
        cl.files.getEmbedLink(forFile: fileItem.id) { (result: Result<ExpiringEmbedLink, BoxSDKError>) in
            guard case let .success(embedLink) = result else {
                print("Error generating file embed link")
                completion("")
                return
            }
            completion("\(embedLink.url)")
            print("File embed URL is \(embedLink.url)")
        }
    }
    
}

extension BoxService: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.window ?? ASPresentationAnchor()
    }
}
