import Foundation
import CoreData

struct APIAnswer : Decodable {
    
    var identifier: String
    var postedDate: Double?
    var title: String
    var authorName: String?
    var url: String?
    var body: String
    var category: String?
    var topics: [APITopic]?
    
    enum CodingKeys : CodingKey, String {
        case identifier = "ID"
        case postedDate
        case title
        case authorName
        case url
        case body
        case category
        case topics
    }
}

@objc(Answer)
open class Answer: _Answer {

	// Custom logic goes here.

    class func importAnswer(_ object: APIAnswer , context: NSManagedObjectContext) throws -> (Answer) {
        
        guard let answer = Answer.findFirstOrCreateWithDictionary(["identifier": object.identifier], context: context) as? Answer else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        answer.identifier = object.identifier
        answer.category = nullOrString(object.category)
        
        if let dateString: TimeInterval = object.postedDate {
            answer.postedDate = Date(timeIntervalSince1970: dateString)
        }
        
        answer.authorName = nullOrString(object.authorName)
        
        answer.url = nullOrString(object.url)

        let articleBody: String = object.body
        answer.body = articleBody
        
        let articleTitle: String = object.title
        answer.title = nullOrString(articleTitle.stringByDecodingHTMLEntities)
        
        
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
            
            answer.topics = myTopics
        }
        
        return answer
    }
    
}
