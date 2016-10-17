import Foundation
import CoreData
import Decodable

@objc(Video)
open class Video: _Video {
    
    class func decodeJSON(_ JSONDict: NSDictionary, context: NSManagedObjectContext, index: Int) throws -> (Video) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        guard let video = Video.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Video else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        video.identifier = try JSONDict => "ID"
        video.thumbnailSource = try JSONDict => "thumbnailSource"
        video.videoIndex = Int32(index)
        
        let channelDescription: String = try JSONDict => "description"
        video.descriptionText = channelDescription.stringByDecodingHTMLEntities
        video.thumbnailAltText = nullOrString(try JSONDict => "thumbnailAltText")
        
        if let dateString: String = try JSONDict => "postedDate" {
            video.postedDate = Date.dateFromTimeString(dateString)
        }
        
        if let dateString: String = try JSONDict => "recordedDate" {
            video.recordedDate = Date.dateFromTimeString(dateString)
        }
        
        video.averageRating = try JSONDict => "averageRating"
        
        video.videoSource = try JSONDict => "videoSource"
        video.videoLength = try JSONDict => "videoLength"
        
        let studyTitle: String = try JSONDict => "title"
        video.title = studyTitle.stringByDecodingHTMLEntities
        
        video.averageRating = nullOrString(try JSONDict => "averageRating")
        
//        if let topicsArray: [NSDictionary] = try JSONDict => "topics" as? [NSDictionary] {
//            //Then lets process the topics
//            var myTopics = Set<Topic>()
//            
//            topicsArray.forEach({ (topicJSONDict) -> () in
//                do {
//                    if let topic = try Topic.decodeJSON(topicJSONDict, context: context) {
//                        myTopics.insert(topic)
//                    }
//                } catch let error {
//                    logger.error("Error decoding Topic \(error)... Skippping...")
//                }
//            })
//            
//            video.topics = myTopics
//        }
        
        return video
    }
    
}
