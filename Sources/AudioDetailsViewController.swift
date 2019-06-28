//
//  AudioDetailsViewController.swift
//  AudioListModule
//
//  Created by Anton Boyarkin on 25/06/2019.
//

import UIKit
import IBACore
import IBACoreUI
import PKHUD

import AVKit
import AVFoundation

class AudioDetailsViewController: BaseViewController {
    private var data: AudioItemModel?
    private var colorScheme: ColorSchemeModel?
    private var moduleId: String?
    
    public var onPlay: ((AudioItemModel) -> Void)?
    
    var canShare = false {
        didSet {
            mainView.canShare = canShare
        }
    }
    
    var canLike = false {
        didSet {
            mainView.canLike = canLike
        }
    }
    
    var canComment = false {
        didSet {
            mainView.canComment = canComment
        }
    }
    
    // MARK: - Controller life cycle methods
    convenience init(with colorScheme: ColorSchemeModel?, data: AudioItemModel?, moduleId: String?) {
        self.init()
        self.data = data
        self.colorScheme = colorScheme
        self.moduleId = moduleId
    }
    
    fileprivate var mainView: AudioDetailsView {
        return self.view as! AudioDetailsView
    }
    
    override public func loadView() {
        if let data = data, let colorScheme = colorScheme {
            view = AudioDetailsView(model: data, colorScheme: colorScheme)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.onPlay = {
            guard let item = self.data else { return }
            self.onPlay?(item)
        }
        
        if let vid = data?.id, let mid = moduleId {
            mainView.onSubmitComment = { name, text in
                HUD.show(.progress)
                AppManager.manager.apiService?.postComment(name: name, text: text, for: "\(vid)", of: "audio", reply: "0", module: mid, {
                    self.loadComments { comments in
                        HUD.hide()
                        self.mainView.setComments(comments)
                    }
                })
            }
            
            loadComments { comments in
                self.mainView.setComments(comments)
            }
        }
        
        mainView.onAddComment = { comment in
            let vc = CommentReplyViewController<AudioItemModel>(with: self.colorScheme, item: self.data, comment: comment, moduleId: self.moduleId)
            vc.canComment = self.canComment
            vc.onReplyPosted = {
                self.loadComments { comments in
                    self.mainView.setComments(comments)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        mainView.onShare = {
            guard let app = AppManager.manager.appModel(), let appConfig = AppManager.manager.config(), let url = self.data?.url else { return }
            let appName = app.design?.appName ?? ""
            var message = String(format: Localization.VideoList.Share.message, url, appName)
            let showLink = app.design?.isShowLink ?? false
            if showLink {
                let link = "https://ibuildapp.com/projects.php?action=info&projectid=\(appConfig.appID)"
                message.append("\n")
                message.append(String(format: Localization.VideoList.Share.link, appName, link))
                message.append("\n")
                message.append(Localization.VideoList.Share.postedVia)
            }
            
            let textToShare = [ message ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func loadComments(_ completion: @escaping ([Comment])->Void) {
        if let vid = data?.id, let mid = moduleId {
            AppManager.manager.apiService?.getComments(for: "\(vid)", of: "audio", reply: "0", module: mid) { comments in
                completion(comments)
            }
        }
    }
}
