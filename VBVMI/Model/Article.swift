import Foundation
import CoreData
import Decodable


@objc(Article)
open class Article: _Article {

	// Custom logic goes here.

    class func decodeJSON(_ JSONDict: [AnyHashable : Any], context: NSManagedObjectContext) throws -> (Article) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        guard let article = Article.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Article else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        article.identifier = try JSONDict => "ID"
        article.category = nullOrString(try JSONDict => "category")
        
        if let dateString: String = try JSONDict => "postedDate" {
            article.postedDate = Date.dateFromTimeString(dateString)
        }
        
        article.authorThumbnailSource = nullOrString(try JSONDict => "authorThumbnailSource")
        article.authorThumbnailAltText = nullOrString(try JSONDict => "authorThumbnailAltText")
        
        article.averageRating = nullOrString(try JSONDict => "averageRating")
        article.authorName = nullOrString(try JSONDict => "authorName")
        
        article.articleThumbnailAltText = nullOrString(try JSONDict => "articleThumbnailAltText")
        article.articleThumbnailSource = nullOrString(try JSONDict => "articleThumbnailSource")
        article.url = nullOrString(try? JSONDict => "url")
//        if let thumbSource = article.articleThumbnailSource {
//            article.articleThumbnailSource = thumbSource.stringByReplacingOccurrencesOfString("SMALL", withString: "")
//        }
        
        let articleDescription: String = try JSONDict => "description"
        article.descriptionText = nullOrString(articleDescription.stringByDecodingHTMLEntities)
        let articleBody: String = try JSONDict => "body"
        article.body = articleBody.stringByDecodingHTMLEntities
        
        let articleTitle: String = try JSONDict => "title"
        article.title = nullOrString(articleTitle.stringByDecodingHTMLEntities)
        
        if let topicsArray: [[AnyHashable: Any]] = try JSONDict => "topics" as? [[AnyHashable: Any]] {
            //Then lets process the topics
            var myTopics = Set<Topic>()
            
            topicsArray.forEach({ (topicJSONDict) -> () in
                do {
                    if let topic = try Topic.decodeJSON(topicJSONDict, context: context) {
                        myTopics.insert(topic)
                    }
                } catch let error {
                    logger.error("Error decoding Topic \(error)... Skippping...")
                }
            })
            
            article.topics = myTopics
        }
        
        return article
    }
}
