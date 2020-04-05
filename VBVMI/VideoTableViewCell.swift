//
//  VideoTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 11/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import VimeoNetworking

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var time: String? {
        get { return timeLabel.text }
        set { timeLabel.text = newValue }
    }
    
    var videoDescription: String? {
        get { return descriptionLabel.text }
        set { descriptionLabel.text = newValue }
    }
    

    var vimeoId: String? {
        didSet {
            if let val = vimeoId {
                loadVimeoContent(vimeoId: val)
            }
        }
    }
    
    private var vimeoRequestToken: VimeoClient.RequestToken?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        thumbnailImageView.layer.cornerRadius = 3.0
        thumbnailImageView.layer.masksToBounds = true
        
        timeLabel.textColor = StyleKit.darkGrey
        titleLabel.textColor = StyleKit.darkGrey
        descriptionLabel.textColor = StyleKit.midGrey
        
        time = " "
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func loadVimeoContent(vimeoId: String) {
        VimeoManager.shared.getVimeoObject(vimeoVideoId: vimeoId, tokenHandler: { [weak self] (token) in
            guard let this = self else {
                token.cancel()
                return
            }
            this.vimeoRequestToken = token
        }) { [weak self] (result) in
            guard let this = self else { return }
            switch result {
            case .failure(let error):
                logger.error("🍕 failure to download vimeo object: \(error)")
            case .success(let vimeoVideo):
                this.time = (vimeoVideo.duration?.doubleValue)?.timeString
                if let imageString = vimeoVideo.pictureCollection?.picture(forWidth: Float(this.thumbnailImageView.frame.size.width * UIScreen.main.scale))?.link, let url = URL(string: imageString) {
                    this.thumbnailImageView?.af_setImage(withURL: url)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        vimeoId = nil
        vimeoRequestToken?.cancel()
        vimeoRequestToken = nil
        title = nil
        time = " "
        videoDescription = nil
        thumbnailImageView?.af_cancelImageRequest()
        thumbnailImageView.image = nil
    }
    
}
