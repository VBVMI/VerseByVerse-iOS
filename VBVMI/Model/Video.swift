import Foundation
import CoreData

struct APIVideo : Decodable {
    var identifier: String
    var thumbnailSource: String
    var serviceIdentifier: String?
    var service: String?
    var channelDescription: String
    var recordedDate: String?
    var videoSource: String
    var videoLength: String
    var videoURL: String?
    var title: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "ID"
        case thumbnailSource
        case serviceIdentifier = "serviceVideoID"
        case service
        case channelDescription = "description"
        case recordedDate
        case videoSource
        case videoLength
        case videoURL = "url"
        case title
    }
}

@objc(Video)
open class Video: _Video {
    
    class func importVideo(_ object: APIVideo, context: NSManagedObjectContext, index: Int) throws -> (Video) {
        
        guard let video = Video.findFirstOrCreateWithDictionary(["identifier": object.identifier], context: context) as? Video else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        video.identifier = object.identifier
        video.thumbnailSource = object.thumbnailSource
        video.videoIndex = Int32(index)
        video.serviceVideoIdentifier = object.serviceIdentifier
        video.service = object.service
        video.descriptionText = object.channelDescription.stringByDecodingHTMLEntities
        
        if let dateString = object.recordedDate {
            video.recordedDate = Date.dateFromTimeString(dateString)
        }
        
        video.videoSource = object.videoSource
        video.videoLength = object.videoLength
        
        video.url = nullOrString(object.videoURL)
        
        video.title = object.title.stringByDecodingHTMLEntities
        
        return video
    }
    
}
