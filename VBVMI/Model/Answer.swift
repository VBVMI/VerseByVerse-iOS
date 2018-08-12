import Foundation
import CoreData
import Decodable

@objc(Answer)
open class Answer: _Answer {

	// Custom logic goes here.

    class func decodeJSON(_ JSONDict: [AnyHashable : Any], context: NSManagedObjectContext) throws -> (Answer) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        guard let answer = Answer.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Answer else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        answer.identifier = try JSONDict => "ID"
        answer.category = nullOrString(try JSONDict => "category")
        
        if let dateString: String = try JSONDict => "postedDate" {
            answer.postedDate = Date.dateFromTimeString(dateString)
        }
        
        answer.authorName = nullOrString(try JSONDict => "authorName")
        
        answer.url = nullOrString(try? JSONDict => "url")
        
        //        if let thumbSource = article.articleThumbnailSource {
        //            article.articleThumbnailSource = thumbSource.stringByReplacingOccurrencesOfString("SMALL", withString: "")
        //        }
        
        let articleBody: String = try JSONDict => "body"
        answer.body = articleBody.stringByDecodingHTMLEntities
        
        let articleTitle: String = try JSONDict => "title"
        answer.title = nullOrString(articleTitle.stringByDecodingHTMLEntities)
        
        
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
            
            answer.topics = myTopics
        }
        
        return answer
    }
    
}
