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
        if let thumbSource = study.thumbnailSource {
            study.imageSource = thumbSource.replacingOccurrences(of: "SMALL", with: "")
        }
        
        let studyDescription: String = try JSONDict => "description"
        study.descriptionText = studyDescription.stringByDecodingHTMLEntities
        study.thumbnailAltText = nullOrString(try JSONDict => "thumbnailAltText")
        study.studyType = try JSONDict => "type"
        
        study.bibleIndex = try JSONDict => "bibleIndex"
        
        let studyTitle: String = try JSONDict => "title"
        study.title = studyTitle.stringByDecodingHTMLEntities
        
        study.podcastLink = nullOrString(try JSONDict => "podcastLink")
        study.averageRating = nullOrString(try JSONDict => "averageRating")
        
        study.lessonCount = try JSONDict => "lessonCount"

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
