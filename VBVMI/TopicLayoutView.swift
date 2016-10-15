//
//  TopicLayoutView.swift
//  VBVMI
//
//  Created by Thomas Carey on 31/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

protocol TopicLayoutViewDelegate: NSObjectProtocol {
    func topicSelected(_ topic: Topic)
}

class TopicLayoutView: UIView {
    
    var topics = [Topic]() {
        didSet {
            configureViews()
            rearrangeViews(self.bounds.size)
        }
    }
    
    var topicSelectedBlock : ((_ topic: Topic) -> ())?
    
    fileprivate var topicViews = [TopicButton]()
    
    fileprivate func configureViews() {
        topicViews.forEach { (view) in
            view.removeFromSuperview()
        }
        topicViews = []
        topics.forEach { (topic) in
            let view = TopicButton(frame: CGRect.zero)
            view.topic = topic
            addSubview(view)
            topicViews.append(view)
            view.addTarget(self, action: #selector(TopicLayoutView.tappedTopicButton(_:)), for: .touchUpInside)
        }
        self.invalidateIntrinsicContentSize()
//        self.setContentHuggingPriority(400, forAxis: UILayoutConstraintAxis.Vertical)
    }
    
    func tappedTopicButton(_ sender: TopicButton) {
        if let topic = sender.topic {
            topicSelectedBlock?(topic)
        }
    }
    
    var lastLayoutSize: CGSize = CGSize.zero {
        didSet {
            if lastLayoutSize.height != oldValue.height {
//                print("setting height to: \(lastLayoutSize)")
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
            }
//            self.snp_updateConstraints { (make) in
//                make.height.equalTo(lastLayoutSize.height)
//            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        rearrangeViews(size)
        return CGSize(width: size.width, height: lastLayoutSize.height)
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: lastLayoutSize.height)
    }
    
    func rearrangeViews(_ size: CGSize) {
        var currentX : CGFloat = self.layoutMargins.left
        var currentY : CGFloat = self.layoutMargins.top
        let paddingH : CGFloat = 8
        let paddingV : CGFloat = 8
        let rightEdgeX = size.width - self.layoutMargins.left - self.layoutMargins.right
        var lastSize: CGSize = CGSize.zero
        var maxWidth : CGFloat = 0
        
        for topicView in topicViews {
            let size = topicView.intrinsicContentSize
            if topicView.isHidden {
                topicView.frame = CGRect.zero
                continue
            }
            if size.width + currentX <= rightEdgeX {
                topicView.frame = CGRect(x: currentX, y: currentY, width: size.width, height: size.height)
                currentX += paddingH + size.width
            } else {
                currentX = self.layoutMargins.left
                currentY += size.height + paddingV
                topicView.frame = CGRect(x: currentX, y: currentY, width: size.width, height: size.height)
                currentX += paddingH + size.width
            }
            if currentX > maxWidth {
                maxWidth = currentX
            }
            lastSize = size
        }
        let totalHeight = currentY + lastSize.height + layoutMargins.bottom
        let totalWidth = maxWidth + layoutMargins.right
        lastLayoutSize = CGSize(width: totalWidth, height: totalHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rearrangeViews(self.bounds.size)
        super.layoutSubviews()
    }
}
