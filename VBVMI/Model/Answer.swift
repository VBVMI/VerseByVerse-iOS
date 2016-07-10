import Foundation
import CoreData
import Decodable


@objc(Answer)
public class Answer: _Answer {

	// Custom logic goes here.

    class func decodeJSON(JSONDict: NSDictionary, context: NSManagedObjectContext) throws -> (Answer) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.MissingID
        }
        
        guard let answer = Answer.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Answer else {
            throw APIDataManagerError.ModelCreationFailed
        }
        
        answer.identifier = try JSONDict => "ID"
        answer.category = nullOrString(try JSONDict => "category")
        
        if let dateString: String = try JSONDict => "postedDate" {
            answer.postedDate = NSDate.dateFromTimeString(dateString)
        }
        
        answer.authorThumbnailSource = nullOrString(try JSONDict => "authorThumbnailSource")
        answer.authorThumbnailAltText = nullOrString(try JSONDict => "authorThumbnailAltText")
        
        answer.averageRating = nullOrString(try JSONDict => "averageRating")
        answer.authorName = nullOrString(try JSONDict => "authorName")
        
        answer.qaThumbnailAltText = nullOrString(try JSONDict => "qAndAThumbnailAltText")
        answer.qaThumbnailSource = nullOrString(try JSONDict => "qAndAThumbnailSource")
        
        //        if let thumbSource = article.articleThumbnailSource {
        //            article.articleThumbnailSource = thumbSource.stringByReplacingOccurrencesOfString("SMALL", withString: "")
        //        }
        
        let articleDescription: String = try JSONDict => "description"
        answer.descriptionText = nullOrString(articleDescription.stringByDecodingHTMLEntities)
        let articleBody: String = try JSONDict => "body"
        answer.body = articleBody.stringByDecodingHTMLEntities
        
        let articleTitle: String = try JSONDict => "title"
        answer.title = nullOrString(articleTitle.stringByDecodingHTMLEntities)
        
        
        if let topicsArray: [NSDictionary] = try JSONDict => "topics" as? [NSDictionary] {
            //Then lets process the topics
            var myTopics = Set<Topic>()
            
            topicsArray.forEach({ (topicJSONDict) -> () in
                do {
                    if let topic = try Topic.decodeJSON(topicJSONDict, context: context) {
                        myTopics.insert(topic)
                    }
                } catch let error {
                    log.error("Error decoding Topic \(error)... Skippping...")
                }
            })
            
            answer.topics = myTopics
        }
        
        return answer
    }
    
}
