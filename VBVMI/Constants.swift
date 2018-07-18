//
//  Constants.swift
//  VBVMI
//
//  Created by Thomas Carey on 3/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import UIKit

enum Cell {
    enum NibName {
        static let Study = "StudyCellCollectionViewCell"
        static let StudiesHeader = "StudiesHeaderReusableView"
        static let Article = "ArticleTableViewCell"
        static let ArticleHeader = "ArticleHeaderTableViewCell"
        static let ArticleBody = "ArticleBodyTableViewCell"
        static let AnswerBody = "AnswerBodyTableViewCell"
        static let AnswerHeader = "AnswerHeaderTableViewCell"
        static let RecentStudies = "RecentHistoryCollectionViewCell"
        static let LatestLessons = "LatestLessonsCollectionViewCell"
    }
    enum Identifier {
        static let Study = "StudyCell"
        static let StudiesHeader = "StudiesHeader"
        static let Article = "ArticleCell"
        static let ArticleHeader = "ArticleHeaderCell"
        static let ArticleBody = "ArticleBodyCell"
        static let AnswerBody = "AnswerBodyCell"
        static let AnswerHeader = "AnswerHeaderCell"
        static let RecentStudies = "RecentStudies"
        static let LatestLessons = "LatestLessons"
    }
    enum CellSize {
        static let Study = CGSize(width: 150, height: 155)
        static let StudyImageInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //Bottom doesn't matter yo
    }
}

enum TabBar {
    static let pointSize: CGFloat = 10
}

enum DateFormatters {
    static let calendarDateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()
    
    static let dayMonthDateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
}

extension UIColor {
    static let darkBackground = UIColor(hue: 1, saturation: 0, brightness: 0.2, alpha: 1)
}
