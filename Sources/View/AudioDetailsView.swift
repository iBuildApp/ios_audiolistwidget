//
//  AudioDetailsView.swift
//  AudioListModule
//
//  Created by Anton Boyarkin on 25/06/2019.
//

import UIKit
import FlexLayout
import PinLayout
import IBACore
import IBACoreUI

public class AudioDetailsView: UIView {
    private let contentView = UIScrollView()
    private let rootFlexContainer = UIView()
    
    public let imageView = UIImageView()
    public let titleLabel = UILabel()
    public let commentsLabel = UILabel()
    public let playButton = PlayButtonView()
    public let likeButton = UIButton(type: .custom)
    public let shareButton = UIButton(type: .custom)
    public let contentTextView = GrowingTextView()
    
    public let commentsConteiner = UIView()
    public let inputConteiner = UIView()
    public var commentInputView: TextInputView!
    
    var canShare = false {
        didSet {
            updateVisibility()
        }
    }
    
    var canLike = false {
        didSet {
            updateVisibility()
        }
    }
    
    var canComment = false {
        didSet {
            updateVisibility()
        }
    }
    
    var onShare: (() -> Void)?
    var onLike: (() -> Void)?
    var onPlay: (() -> Void)?
    var onAddComment: ((_ model: Comment) -> Void)?
    
    var onSubmitComment: ((_ name: String, _ text: String) -> Void)?
    
    private let model: AudioItemModel
    private let colorScheme: ColorSchemeModel
    
    private var commentViews: [CommentView] = []
    
    init(model: AudioItemModel, colorScheme: ColorSchemeModel) {
        self.model = model
        self.colorScheme = colorScheme
        super.init(frame: .zero)
        
        backgroundColor = colorScheme.backgroundColor
        
        commentInputView = TextInputView(colorScheme: colorScheme)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        
        likeButton.setTitle("0", for: .normal)
        likeButton.titleLabel?.font = .systemFont(ofSize: 16.0)
        likeButton.setImage(getCoreUIImage(with: "like"), for: .normal)
        likeButton.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 15)
        likeButton.tintColor = colorScheme.textColor.withAlphaComponent(0.6)
        likeButton.setTitleColor(colorScheme.textColor.withAlphaComponent(0.6), for: .normal)
        likeButton.sizeToFit()
        
        shareButton.setTitle(Localization.Common.Text.share, for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 16.0)
        shareButton.setImage(getCoreUIImage(with: "share"), for: .normal)
        shareButton.titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: -8)
        shareButton.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
        shareButton.tintColor = colorScheme.textColor.withAlphaComponent(0.6)
        shareButton.setTitleColor(colorScheme.textColor.withAlphaComponent(0.6), for: .normal)
        shareButton.sizeToFit()
        
        playButton.backgroundColor = .black
        playButton.layer.cornerRadius = 20
        playButton.onTap = { isPlaying in
            if isPlaying {
                self.play()
            } else {
                AppManager.manager.mediaPlayer?.stop()
            }
        }
        
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = colorScheme.accentColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 0
        
        commentsLabel.font = .systemFont(ofSize: 16)
        commentsLabel.textColor = colorScheme.secondaryColor
        commentsLabel.lineBreakMode = .byTruncatingTail
        commentsLabel.numberOfLines = 0
        commentsLabel.text = Localization.Common.Comments.commets(0)
        
        contentTextView.font = .systemFont(ofSize: 14)
        contentTextView.textColor = colorScheme.textColor
        contentTextView.contentInset = .zero
        contentTextView.backgroundColor = .clear
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        contentTextView.isSelectable = false
        
        rootFlexContainer.flex.define { (flex) in
            flex.addItem().direction(.row).margin(8).define({ flex in
                if model.coverImageUrl != nil {
                    flex.addItem(imageView).width(20%).aspectRatio(1).marginRight(8)
                }
                flex.addItem().direction(.column).grow(1).shrink(1).define({ flex in
                    flex.addItem(titleLabel)
                    flex.addItem(contentTextView)
                    flex.addItem().addItem().direction(.row).justifyContent(.spaceBetween).define({ flex in
                        flex.addItem(playButton).size(40)
                        flex.addItem(shareButton).height(40)
                    })
                })
            })
            
            flex.addItem().height(1).backgroundColor(.lightGray)
            flex.addItem(commentsLabel).marginHorizontal(20).marginVertical(8)
            flex.addItem().height(1).backgroundColor(.lightGray)
            flex.addItem(commentsConteiner)
        }

        contentView.addSubview(rootFlexContainer)

        addSubview(contentView)

        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)

        titleLabel.text = model.title
        titleLabel.flex.markDirty()

        contentTextView.text = model.description
        contentTextView.flex.markDirty()

        if let url = model.coverImageUrl {
            imageView.kf.setImage(with: url, placeholder: getCoreUIImage(with: "placeholder_image"))
        }
        
        flex.layout()
        
        addSubview(commentInputView)
        addSubview(inputConteiner)
        
        updateVisibility()
        
        inputConteiner.backgroundColor = commentInputView.backgroundColor
        
        commentInputView.pin.bottom(pin.safeArea).right().left()
        commentInputView.flex.layout(mode: .adjustHeight)
        inputConteiner.pin.bottomLeft().right().below(of: commentInputView)
        
        commentInputView.onSubmit = { name, text in
            self.onSubmitComment?(name, text)
        }
        
        if let currentTrackId = AppManager.manager.mediaPlayer?.currentTrackId, currentTrackId == "\(model.id)" {
            playButton.play()
        } else {
            playButton.stop()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        commentInputView.pin.bottom(pin.safeArea).right().left()
        commentInputView.flex.layout(mode: .adjustHeight)
        inputConteiner.pin.bottomLeft().right().below(of: commentInputView)
        
        let inputHeight = commentInputView.bounds.height + inputConteiner.bounds.height
        
        // 1) Layout the contentView & rootFlexContainer using PinLayout
        contentView.pin.all(pin.safeArea)
        rootFlexContainer.pin.top().left().right()
        
        // 2) Let the flexbox container layout itself and adjust the height
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        // 3) Adjust the scrollview contentSize
        var size = rootFlexContainer.frame.size
        if canComment {
            size.height += inputHeight
        }
        contentView.contentSize = size
    }
    
    @objc func share() {
        onShare?()
    }
    
    @objc func like() {
        onLike?()
    }
    
    @objc func play() {
        onPlay?()
    }
    
    func updateVisibility() {
        shareButton.isHidden = !canShare
        likeButton.isHidden = !canLike
        commentInputView.isHidden = !canComment
        inputConteiner.isHidden = !canComment
    }
    
    func setComments(_ comments: [Comment]) {
        commentsLabel.text = Localization.Common.Comments.commets(comments.count)
        commentsLabel.flex.markDirty()
        
        for view in commentViews {
            view.isHidden = true
            view.flex.isIncludedInLayout(false)
            view.removeFromSuperview()
        }
        
        commentViews.removeAll()
        
        commentsConteiner.flex.define { flex in
            for comment in comments {
                let view = CommentView(model: comment, colorScheme: colorScheme)
                view.onAddComment = { comment in
                    self.onAddComment?(comment)
                }
                self.commentViews.append(view)
                flex.addItem(view)
            }
        }
        
        commentsConteiner.flex.markDirty()
        
        setNeedsLayout()
    }
}
