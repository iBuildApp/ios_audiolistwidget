//
//  AudioListViewController.swift
//  AudioListModule
//
//  Created by Anton Boyarkin on 25/06/2019.
//

import UIKit
import IBACore
import IBACoreUI
import Kingfisher
import PinLayout
import FlexLayout
import AVFoundation

class AudioListViewController: BaseListViewController<AudioItemCell> {
    // MARK: - Private properties
    /// Widget type indentifier
    private var type: String?
    
    /// Widger config data
    private var data: DataModel?
    
    private var colorScheme: ColorSchemeModel?
    
    // MARK: - Controller life cycle methods
    public convenience init(type: String?, data: DataModel?) {
        let colorScheme = data?.colorScheme ?? AppManager.manager.appModel()?.design?.colorScheme
        self.init(with: colorScheme, data: data?.tracks)
        self.type = type
        self.data = data
        self.colorScheme = colorScheme
        if let mid = data?.moduleId {
            AppManager.manager.apiService?.getCommentsCount(for: mid, of: "audio", { commentCounts in
                print(commentCounts)
                for commentCount in commentCounts {
                    let track = self.data?.tracks?.first(where: { track -> Bool in
                        track.id == commentCount.id
                    })
                    track?.commentsCount = commentCount.total_comments
                }
                self.configure(data: self.data?.tracks ?? [])
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView()
        imageView.frame.size.height = 200
        imageView.kf.setImage(with: data?.coverImageUrl)
        self.tableView.tableHeaderView = imageView
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = .white
        
        self.onItemSelect = { item in
            let vc = AudioDetailsViewController(with: self.colorScheme, data: item, moduleId: self.data?.moduleId)
            vc.canShare = self.data?.canShare ?? false
            vc.canComment = self.data?.canComment ?? false
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        self.onItemAction = { item in
            self.play(item)
            
            NotificationCenter.default.post(name: .trackDidChanged, object: self, userInfo: nil)
        }
        
        AppManager.manager.mediaPlayer?.onTrackChanged = {
            NotificationCenter.default.post(name: .trackDidChanged, object: self, userInfo: ["currentTrackId": AppManager.manager.mediaPlayer?.currentTrackId ?? ""])
        }
    }
    deinit {
        AppManager.manager.mediaPlayer?.onTrackChanged = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.post(name: .trackDidChanged, object: self, userInfo: ["currentTrackId": AppManager.manager.mediaPlayer?.currentTrackId ?? ""])
    }
    
    func play(_ item: AudioItemModel) {
        guard let tracks = data?.tracks, let trackIndex = tracks.firstIndex(where: { $0 == item }) else { return }
        
        var playlist = [MediaItem]()
        for track in tracks {
            let item = MediaItem(id: "\(track.id)", title: track.title, mediaUrl: track.stream_url ?? "", coverUrl: track.coverImageUrl)
            playlist.append(item)
        }
        
        AppManager.manager.mediaPlayer?.setPlaylist(playlist, startIndex: trackIndex)
    }
}
