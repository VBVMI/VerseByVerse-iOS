import Foundation
import CoreData
import Decodable

@objc(Video)
open class Video: _Video {
    
    class func decodeJSON(_ JSONDict: [AnyHashable : Any], context: NSManagedObjectContext, index: Int) throws -> (Video) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        guard let video = Video.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Video else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        video.identifier = try JSONDict => "ID"
        video.thumbnailSource = try JSONDict => "thumbnailSource"
        video.videoIndex = Int32(index)
        video.serviceVideoIdentifier = try? JSONDict => "serviceVideoID"
        video.service = try? JSONDict => "service"
        
        let channelDescription: String = try JSONDict => "description"
        video.descriptionText = channelDescription.stringByDecodingHTMLEntities
        
        if let dateString: String = try JSONDict => "recordedDate" {
            video.recordedDate = Date.dateFromTimeString(dateString)
        }
        
        video.videoSource = try JSONDict => "videoSource"
        video.videoLength = try JSONDict => "videoLength"
        
        video.url = nullOrString(try JSONDict => "url")
        
        let studyTitle: String = try JSONDict => "title"
        video.title = studyTitle.stringByDecodingHTMLEntities
        
        return video
    }
    
}
