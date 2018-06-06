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
    }
    enum CellSize {
        static let Study = CGSize(width: 90, height: 144)
        static let StudyImageInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) //Bottom doesn't matter yo
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

}
