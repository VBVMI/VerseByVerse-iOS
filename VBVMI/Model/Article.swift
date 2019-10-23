import Foundation
import CoreData

struct APIArticle : Decodable {
    
    var identifier: String
    var summary: String?
    var postedDate: Double?
    var title: String
    var authorName: String?
    var authorThumbnailSource: String?
    var authorThumbnailAltText: String?
    var url: String?
    var body: String
    var category: String?
    var topics: [APITopic]?
    
    enum CodingKeys : String, CodingKey {
        case identifier = "ID"
        case summary
        case postedDate
        case title
        case authorName
        case authorThumbnailSource
        case authorThumbnailAltText
        case url
        case body
        case category
        case topics
    }
}

@objc(Article)
open class Article: _Article {

	// Custom logic goes here.

    class func importArticle(_ object: APIArticle, context: NSManagedObjectContext) throws -> (Article) {
        
        guard let article = Article.findFirstOrCreateWithDictionary(["identifier": object.identifier], context: context) as? Article else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        article.identifier = object.identifier
        article.category = nullOrString(object.category)
        
        if let dateString: TimeInterval = object.postedDate {
            article.postedDate = Date(timeIntervalSince1970: dateString)
        }
        
        article.authorThumbnailSource = nullOrString(object.authorThumbnailSource)
        article.authorThumbnailAltText = nullOrString(object.authorThumbnailAltText)
        
        article.summary = nullOrString(object.summary)
        article.authorName = nullOrString(object.authorName)
        
        article.url = nullOrString(object.url)

        let articleBody: String = object.body
        article.body = articleBody
        
        let articleTitle: String = object.title
        article.title = nullOrString(articleTitle.stringByDecodingHTMLEntities)
        
        
        if let topicsArray = object.topics {
            //Then lets process the topics
            var myTopics = Set<Topic>()
            
            topicsArray.forEach({ (topicAPI) -> () in
                do {
                    if let topic = try Topic.importTopic(topicAPI, context: context) {
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
