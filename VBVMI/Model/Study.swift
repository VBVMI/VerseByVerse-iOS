import Foundation
import CoreData
import Decodable

@objc(Study)
open class Study: _Study {

	// Custom logic goes here.
    class func decodeJSON(_ JSONDict: NSDictionary, context: NSManagedObjectContext, index: Int) throws -> (Study) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        guard let study = Study.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Study else {
            throw APIDataManagerError.modelCreationFailed
        }

        study.identifier = try JSONDict => "ID"
        study.thumbnailSource = try JSONDict => "thumbnailSource"
        study.studyIndex = Int32(index)
    
        study.descriptionText = try JSONDict => "description"
        study.thumbnailAltText = nullOrString(try JSONDict => "thumbnailAltText")
        study.category = "\(JSONDict["category"] ?? 0)" // Catedory identifier needs to be a string
        
        study.studyCategory = StudyCategory.findFirstWithPredicate(NSPredicate(format: "identifier MATCHES %@", study.category), context: context)
        
        study.bibleIndex = try JSONDict => "bibleIndex"
        
        let studyTitle: String = try JSONDict => "title"
        study.title = studyTitle.stringByDecodingHTMLEntities
        
        study.podcastLink = nullOrString(try JSONDict => "podcastLink")
        study.averageRating = nullOrString(try JSONDict => "averageRating")
        
        study.lessonCount = try JSONDict => "lessonCount"
        study.url = nullOrString(try JSONDict => "url")
        
        study.image160 = nullOrString(try JSONDict => "image160")
        study.image300 = nullOrString(try JSONDict => "image300")
        study.image600 = nullOrString(try JSONDict => "image600")
        study.image900 = nullOrString(try JSONDict => "image900")
        study.image1100 = nullOrString(try JSONDict => "image1100")
        study.image1400 = nullOrString(try JSONDict => "image1400")
        
        if let topicsArray: [NSDictionary] = try JSONDict => "topics" as? [NSDictionary] {
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
            
            study.topics = myTopics
        }
        
        return study
    }

}
