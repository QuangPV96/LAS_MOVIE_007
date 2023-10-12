//
//  DatabaseManager.swift
//  LastMovie007
//
//  Created by Tran Cuong on 06/10/2023.
//

import FMDB
import Photos

enum VideoListType {
    case history
    case favourite
    case home
    case box
}

class DatabaseManager {
    static let shared = DatabaseManager()
    let database: FMDatabase
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentsDirectory.appendingPathComponent("myDatabase.db")
        database = FMDatabase(url: databaseURL)
        
        if !database.open() {
            print("DatabaseManager: Could not open database.")
        } else {
            createTablesIfNeeded()
        }
    }
    
    func createTablesIfNeeded() {
        createHistoryTable()
        createFavouritesTable()
        createBoxTable()
    }
    
    func createHistoryTable() {
        do {
            try database.executeUpdate("CREATE TABLE IF NOT EXISTS history (id INTEGER PRIMARY KEY, video_id TEXT, video_name TEXT, video_url TEXT, video_date TEXT, video_duration TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)", values: nil)
        } catch {
            print("DatabaseManager: Error creating history table: \(error.localizedDescription)")
        }
    }
    
    func createBoxTable() {
        do {
            try database.executeUpdate("CREATE TABLE IF NOT EXISTS box (id INTEGER PRIMARY KEY, video_id TEXT, video_name TEXT, video_url TEXT, video_date TEXT, video_duration TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)", values: nil)
        } catch {
            print("DatabaseManager: Error creating box table: \(error.localizedDescription)")
        }
    }
    
    func createFavouritesTable() {
        do {
            try database.executeUpdate("CREATE TABLE IF NOT EXISTS favourites (id INTEGER PRIMARY KEY, video_id TEXT, video_name TEXT, video_url TEXT, video_date TEXT, video_duration TEXT)", values: nil)
        } catch {
            print("DatabaseManager: Error creating favourites table: \(error.localizedDescription)")
        }
    }
    
    func addVideo(type:VideoListType, videoAsset: PHAsset){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        let formattedDate = dateFormatter.string(from: videoAsset.creationDate ?? Date())
        let duration = Utils.stringFromTimeInterval(interval: videoAsset.duration);
        if(type == VideoListType.history){
            let localIdentifier = videoAsset.localIdentifier
            let assetName = Utils.getOriginalFilenameVideo(video: videoAsset)
            let assetURL = videoAsset.value(forKey: "filename") as? String ?? ""
            
            self.addVideoToHistory(videoId: localIdentifier, videoName: assetName, videoURL: assetURL, videoDate: formattedDate, videoDuration: duration)
        }else{
            let localIdentifier = videoAsset.localIdentifier
            let assetName = Utils.getOriginalFilenameVideo(video: videoAsset)
            let assetURL = videoAsset.value(forKey: "filename") as? String ?? ""
            
            self.addVideoToFavourites(videoId: localIdentifier, videoName: assetName, videoURL: assetURL, videoDate: formattedDate, videoDuration: duration)
        }
    }
    
    func addVideoToHistory(videoId: String, videoName: String, videoURL: String, videoDate: String, videoDuration: String) {
        if !videoExistsInHistory(videoId: videoId) {
            // Nếu video không tồn tại trong danh sách yêu thích, thêm nó vào
            do {
                try database.executeUpdate("INSERT INTO history (video_id, video_name, video_url, video_date, video_duration) VALUES (?, ?, ?, ?, ?)", values: [videoId, videoName, videoURL, videoDate, videoDuration])
            } catch {
                print("Error adding video to history: \(error.localizedDescription)")
            }
        } else {
            // Xử lý khi video đã tồn tại
        }
    }
    
    func addVideoToBox(videoId: String, videoName: String, videoURL: String, videoDate: String, videoDuration: String) {
        if !videoExistsInBox(videoId: videoId) {
            // Nếu video không tồn tại trong danh sách yêu thích, thêm nó vào
            do {
                try database.executeUpdate("INSERT INTO box (video_id, video_name, video_url, video_date, video_duration) VALUES (?, ?, ?, ?, ?)", values: [videoId, videoName, videoURL, videoDate, videoDuration])
            } catch {
                print("Error adding video to box: \(error.localizedDescription)")
            }
        } else {
            // Xử lý khi video đã tồn tại
        }
    }
    
    func addVideoToFavourites(videoId: String, videoName: String, videoURL: String, videoDate: String, videoDuration: String) {
        if !videoExistsInFavourites(videoId: videoId) {
            // Nếu video không tồn tại trong danh sách yêu thích, thêm nó vào
            do {
                try database.executeUpdate("INSERT INTO favourites (video_id, video_name, video_url, video_date, video_duration) VALUES (?, ?, ?, ?, ?)", values: [videoId, videoName, videoURL, videoDate, videoDuration])
            } catch {
                print("Error adding video to favourites: \(error.localizedDescription)")
            }
        } else {
            // Xử lý khi video đã tồn tại
        }
        
    }
    
    func removeVideoFromFavourites(videoId: String) {
        do {
            try database.executeUpdate("DELETE FROM favourites WHERE video_id = ?", values: [videoId])
        } catch {
            print("Error removing video from favourites: \(error.localizedDescription)")
        }
    }
    
    func removeVideoFromBox(videoId: String) {
        do {
            try database.executeUpdate("DELETE FROM box WHERE video_id = ?", values: [videoId])
        } catch {
            print("Error removing video from box: \(error.localizedDescription)")
        }
    }
    
    func getHistoryVideos() -> [Video] {
        var videos: [Video] = []
        do {
            let resultSet = try database.executeQuery("SELECT * FROM history", values: nil)
            while resultSet.next() {
                if let videoId = resultSet.string(forColumn: "video_id"),
                   let videoName = resultSet.string(forColumn: "video_name"),
                   let videoURL = resultSet.string(forColumn: "video_url"),
                   let videoDate = resultSet.string(forColumn: "video_date"),
                   let videoDuration = resultSet.string(forColumn: "video_duration") {
                    let video = Video(id: videoId, name: videoName, url: videoURL, date: videoDate, duration: videoDuration)
                    videos.append(video)
                }
            }
        } catch {
            print("Error fetching history videos: \(error.localizedDescription)")
        }
        return videos
    }
    
    func getBoxVideos() -> [Video] {
        var videos: [Video] = []
        do {
            let resultSet = try database.executeQuery("SELECT * FROM box", values: nil)
            while resultSet.next() {
                if let videoId = resultSet.string(forColumn: "video_id"),
                   let videoName = resultSet.string(forColumn: "video_name"),
                   let videoURL = resultSet.string(forColumn: "video_url"),
                   let videoDate = resultSet.string(forColumn: "video_date"),
                   let videoDuration = resultSet.string(forColumn: "video_duration") {
                    let video = Video(id: videoId, name: videoName, url: videoURL, date: videoDate, duration: videoDuration)
                    videos.append(video)
                }
            }
        } catch {
            print("Error fetching history videos: \(error.localizedDescription)")
        }
        return videos
    }
    
    func getFavouriteVideos() -> [Video] {
        var videos: [Video] = []
        do {
            let resultSet = try database.executeQuery("SELECT * FROM favourites", values: nil)
            while resultSet.next() {
                if let videoId = resultSet.string(forColumn: "video_id"),
                   let videoName = resultSet.string(forColumn: "video_name"),
                   let videoURL = resultSet.string(forColumn: "video_url"),
                   let videoDate = resultSet.string(forColumn: "video_date"),
                   let videoDuration = resultSet.string(forColumn: "video_duration") {
                    let video = Video(id: videoId, name: videoName, url: videoURL, date: videoDate, duration: videoDuration)
                    videos.append(video)
                }
            }
        } catch {
            print("Error fetching favourite videos: \(error.localizedDescription)")
        }
        return videos
    }
    
    func removeVideosFromHistory(type:VideoListType, videoList: [Video]) {
        for video in videoList {
            do {
                if(type == VideoListType.history){
                    try database.executeUpdate("DELETE FROM history WHERE video_id = ?", values: [video.id])
                }else if(type == VideoListType.box){
                    try database.executeUpdate("DELETE FROM box WHERE video_id = ?", values: [video.id])
                }else{
                    try database.executeUpdate("DELETE FROM favourite WHERE video_id = ?", values: [video.id])
                }
                
            } catch {
                print("Error removing video from history: \(error.localizedDescription)")
            }
        }
    }
    
    func videoExistsInFavourites(videoId: String) -> Bool {
        do {
            let resultSet = try database.executeQuery("SELECT COUNT(*) AS count FROM favourites WHERE video_id = ?", values: [videoId])
            if resultSet.next() {
                let count = resultSet.int(forColumn: "count")
                return count > 0
            }
        } catch {
            print("Error checking if video exists in favourites: \(error.localizedDescription)")
        }
        return false
    }
    
    func videoExistsInHistory(videoId: String) -> Bool {
        do {
            let resultSet = try database.executeQuery("SELECT COUNT(*) AS count FROM history WHERE video_id = ?", values: [videoId])
            if resultSet.next() {
                let count = resultSet.int(forColumn: "count")
                return count > 0
            }
        } catch {
            print("Error checking if video exists in favourites: \(error.localizedDescription)")
        }
        return false
    }
    
    func videoExistsInBox(videoId: String) -> Bool {
        do {
            let resultSet = try database.executeQuery("SELECT COUNT(*) AS count FROM box WHERE video_id = ?", values: [videoId])
            if resultSet.next() {
                let count = resultSet.int(forColumn: "count")
                return count > 0
            }
        } catch {
            print("Error checking if video exists in favourites: \(error.localizedDescription)")
        }
        return false
    }
}
