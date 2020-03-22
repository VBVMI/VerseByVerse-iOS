import Foundation
import CoreData

struct APIChannels: Decodable {
    var channels: [APIChannel]
}

struct APIChannel : Decodable {
    var identifier: String
    var thumbnailSource: String
    var postedDate: TimeInterval?
    var title: String
    var url: String?
    var videos: [APIVideo]?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "ID"
        case thumbnailSource
        case postedDate
        case title
        case url
        case videos
    }
}

@objc(Channel)
open class Channel: _Channel {

    class func importChannel(_ object: APIChannel, context: NSManagedObjectContext, index: Int) throws -> (Channel) {
        guard let channel = Channel.findFirstOrCreateWithDictionary(["identifier": object.identifier], context: context) as? Channel else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        channel.identifier = object.identifier
        channel.thumbnailSource = object.thumbnailSource
        channel.channelIndex = Int32(index)
        
        if let dateString: TimeInterval = object.postedDate {
            channel.postedDate = Date(timeIntervalSince1970: dateString)
        }
        
        
        channel.title = object.title.stringByDecodingHTMLEntities
        
        channel.url = nullOrString(object.url)
        
        if let videosArray = object.videos {
            //Then lets process the videos
            var myVideos = Set<Video>()
            
            videosArray.enumerated().forEach({ (videoIndex, videoObject) -> () in
                do {
                    let video = try Video.importVideo(videoObject, context: context, index: videoIndex)
                    myVideos.insert(video)
                } catch let error {
                    logger.error("Error decoding Video \(error)... Skippping...")
                }
            })
            
            channel.videos = myVideos
        }
        
        return channel
    }
}
