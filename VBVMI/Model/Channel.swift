import Foundation
import CoreData

@objc(Channel)
open class Channel: _Channel {

    class func decodeJSON(_ JSONDict: [AnyHashable : Any], context: NSManagedObjectContext, index: Int) throws -> (Channel) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        guard let channel = Channel.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Channel else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        channel.identifier = try JSONDict => "ID"
        channel.thumbnailSource = try JSONDict => "thumbnailSource"
        channel.channelIndex = Int32(index)
        
        if let dateString: TimeInterval = try JSONDict => "postedDate" {
            channel.postedDate = Date(timeIntervalSince1970: dateString)
        }
        
        let studyTitle: String = try JSONDict => "title"
        channel.title = studyTitle.stringByDecodingHTMLEntities
        
        channel.url = nullOrString(try JSONDict => "url")
        
        if let videosArray: [[AnyHashable: Any]] = try JSONDict => "videos" as? [[AnyHashable: Any]] {
            //Then lets process the videos
            var myVideos = Set<Video>()
            
            videosArray.enumerated().forEach({ (videoIndex, topicJSONDict) -> () in
                do {
                    let video = try Video.decodeJSON(topicJSONDict, context: context, index: videoIndex)
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
