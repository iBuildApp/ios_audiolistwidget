//
//  AudioItemCell.swift
//  AudioListModule
//
//  Created by Anton Boyarkin on 25/06/2019.
//

import UIKit
import IBACore
import IBACoreUI
import PinLayout
import FlexLayout
import Kingfisher

extension Notification.Name {
    static let trackDidChanged = Notification.Name("trackDidChanged")
}

public class PlayButtonView: UIControl {
    
    let indicator = ESTMusicIndicatorView.init(frame: CGRect.zero)
    let playIcon = UIImageView(image: getCoreUIImage(with: "play"))
    
    public var onTap: ((Bool) -> Void)?
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .black
        layer.cornerRadius = 10
        
        playIcon.sizeToFit()
        
        indicator.state = .stopped
        indicator.tintColor = .white
        indicator.sizeToFit()
        
        sv(playIcon, indicator)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        playIcon.pin.vCenter().hCenter(2)
        indicator.pin.center()
    }
    
    // MARK: - Touch
    @objc private func handleTapGesture(recognizer: UITapGestureRecognizer) {
        toggle()
        onTap?(playIcon.isHidden)
    }
    
    func toggle() {
        playIcon.isHidden = !playIcon.isHidden
        indicator.state = playIcon.isHidden ? .playing : .stopped
    }
    
    func play() {
        DispatchQueue.main.async {
            self.playIcon.isHidden = true
            self.indicator.state = .playing
        }
    }
    
    func stop() {
        DispatchQueue.main.async {
            self.playIcon.isHidden = false
            self.indicator.state = .stopped
        }
    }
}

class AudioItemCell: UITableViewCell, BaseCellType {
    typealias ModelType = AudioItemModel
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    private var model: ModelType?
    
    private let padding: CGFloat = 8
    private let titleLabel = UILabel()
    private let lotalCommentsLabel = UIButton(type: .custom)
    
    public let playButton = PlayButtonView()
    public var onAction: ((ModelType) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        
        lotalCommentsLabel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        lotalCommentsLabel.setBackgroundImage(getCoreUIImage(with: "comment_counter"), for: .normal)
        lotalCommentsLabel.setTitleColor(.white, for: .normal)
        lotalCommentsLabel.contentEdgeInsets = .init(top: 5, left: 10, bottom: 10, right: 10)
        lotalCommentsLabel.sizeToFit()
        lotalCommentsLabel.isUserInteractionEnabled = false
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        playButton.backgroundColor = .black
        playButton.layer.cornerRadius = 20
        
        playButton.onTap = { isPlaying in
            if isPlaying {
                self.play()
            } else {
                AppManager.manager.mediaPlayer?.stop()
            }
        }
        
        // Use contentView as the root flex container
        contentView.flex.padding(10).addItem().direction(.row).define { flex in
            flex.addItem(playButton).size(40)
            flex.addItem(titleLabel).marginHorizontal(padding).maxWidth(80%)
            flex.addItem(lotalCommentsLabel).right(0).position(.absolute).alignSelf(.center)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTrackChanded(_:)), name: .trackDidChanged, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configure(model: ModelType) {
        self.model = model
        titleLabel.text = model.title
        titleLabel.flex.markDirty()
        
        lotalCommentsLabel.setTitle(model.commentsCount, for: .normal)
        lotalCommentsLabel.sizeToFit()
        lotalCommentsLabel.flex.markDirty()
        
        flex.layout()
        
        if let currentTrackId = AppManager.manager.mediaPlayer?.currentTrackId, currentTrackId == "\(model.id)" {
            playButton.play()
        } else {
            playButton.stop()
        }
    }
    
    func setColorScheme(_ colorScheme: ColorSchemeModel) {
        titleLabel.textColor = colorScheme.secondaryColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    fileprivate func layout() {
        contentView.flex.layout(mode: .adjustHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 1) Set the contentView's width to the specified size parameter
        contentView.pin.width(size.width)
        
        // 2) Layout contentView flex container
        layout()
        
        // Return the flex container new size
        return contentView.frame.size
    }
    
    @objc func play() {
        if let model = model {
            onAction?(model)
        }
    }
    
    @objc func onTrackChanded(_ notification: Notification) {
//        if let data = notification.userInfo as? [String: Int64], let id = data["currentTrackId"] {
//            if model?.id == id {
//                playButton.play()
//            } else {
//                playButton.stop()
//            }
//        }
        if let currentTrackId = AppManager.manager.mediaPlayer?.currentTrackId, let model = model, currentTrackId == "\(model.id)" {
            playButton.play()
        } else {
            playButton.stop()
        }
    }
}
