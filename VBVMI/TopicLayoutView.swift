//
//  TopicLayoutView.swift
//  VBVMI
//
//  Created by Thomas Carey on 31/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

protocol TopicLayoutViewDelegate: NSObjectProtocol {
    func topicSelected(topic: Topic)
}

class TopicLayoutView: UIView {
    
    var topics = [Topic]() {
        didSet {
            configureViews()
            rearrangeViews(self.bounds.size)
        }
    }
    
    var topicSelectedBlock : ((topic: Topic) -> ())?
    
    private var topicViews = [TopicButton]()
    
    private func configureViews() {
        topicViews.forEach { (view) in
            view.removeFromSuperview()
        }
        topicViews = []
        topics.forEach { (topic) in
            let view = TopicButton(frame: CGRectZero)
            view.topic = topic
            addSubview(view)
            topicViews.append(view)
            view.addTarget(self, action: #selector(TopicLayoutView.tappedTopicButton(_:)), forControlEvents: .TouchUpInside)
        }
        self.invalidateIntrinsicContentSize()
//        self.setContentHuggingPriority(400, forAxis: UILayoutConstraintAxis.Vertical)
    }
    
    func tappedTopicButton(sender: TopicButton) {
        if let topic = sender.topic {
            topicSelectedBlock?(topic: topic)
        }
    }
    
    var lastLayoutSize: CGSize = CGSizeZero {
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
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        rearrangeViews(size)
        return CGSize(width: size.width, height: lastLayoutSize.height)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, lastLayoutSize.height)
    }
    
    func rearrangeViews(size: CGSize) {
        var currentX : CGFloat = self.layoutMargins.left
        var currentY : CGFloat = self.layoutMargins.top
        let paddingH : CGFloat = 8
        let paddingV : CGFloat = 8
        let rightEdgeX = size.width - self.layoutMargins.left - self.layoutMargins.right
        var lastSize: CGSize = CGSizeZero
        var maxWidth : CGFloat = 0
        
        for topicView in topicViews {
            let size = topicView.intrinsicContentSize()
            if topicView.hidden {
                topicView.frame = CGRectZero
                continue
            }
            if size.width + currentX <= rightEdgeX {
                topicView.frame = CGRectMake(currentX, currentY, size.width, size.height)
                currentX += paddingH + size.width
            } else {
                currentX = self.layoutMargins.left
                currentY += size.height + paddingV
                topicView.frame = CGRectMake(currentX, currentY, size.width, size.height)
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
