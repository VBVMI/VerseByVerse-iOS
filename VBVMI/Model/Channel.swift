import Foundation
import CoreData
import Decodable

@objc(Channel)
public class Channel: _Channel {

    class func decodeJSON(JSONDict: NSDictionary, context: NSManagedObjectContext, index: Int) throws -> (Channel) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.MissingID
        }
        
        guard let channel = Channel.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Channel else {
            throw APIDataManagerError.ModelCreationFailed
        }
        
        channel.identifier = try JSONDict => "ID"
        channel.thumbnailSource = try JSONDict => "thumbnailSource"
        channel.channelIndex = Int32(index)
        
        let channelDescription: String = try JSONDict => "description"
        channel.descriptionText = channelDescription.stringByDecodingHTMLEntities
        channel.thumbnailAltText = nullOrString(try JSONDict => "thumbnailAltText")
        
        if let dateString: String = try JSONDict => "postedDate" {
            channel.postedDate = NSDate.dateFromTimeString(dateString)
        }
        
        let studyTitle: String = try JSONDict => "title"
        channel.title = studyTitle.stringByDecodingHTMLEntities
        
        channel.averageRating = nullOrString(try JSONDict => "averageRating")
        
        if let videosArray: [NSDictionary] = try JSONDict => "videos" as? [NSDictionary] {
            //Then lets process the videos
            var myVideos = Set<Video>()
            
            videosArray.enumerate().forEach({ (videoIndex, topicJSONDict) -> () in
                do {
                    let video = try Video.decodeJSON(topicJSONDict, context: context, index: videoIndex)
                    myVideos.insert(video)
                } catch let error {
                    log.error("Error decoding Video \(error)... Skippping...")
                }
            })
            
            channel.videos = myVideos
        }
        
        return channel
    }
}
