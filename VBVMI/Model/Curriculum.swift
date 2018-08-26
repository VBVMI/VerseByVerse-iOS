import Foundation
import CoreData
import Decodable

@objc(Curriculum)
open class Curriculum: _Curriculum {
	// Custom logic goes here.
    
    class func decodeJSON(_ JSONDict: [AnyHashable : Any], context: NSManagedObjectContext, index: Int) throws -> (Curriculum) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        guard let channel = Curriculum.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Curriculum else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        channel.identifier = try JSONDict => "ID"
        channel.pdfURL = try JSONDict => "pdf"
        
        if let dateString: TimeInterval = try JSONDict => "postedDate" {
            channel.postedDate = Date(timeIntervalSince1970: dateString)
        }
        
        let studyTitle: String = try JSONDict => "title"
        channel.title = studyTitle.stringByDecodingHTMLEntities
        
        channel.url = nullOrString(try JSONDict =>? "url")
        channel.coverImage = nullOrString(try JSONDict =>? "cover_image")
        
        channel.purchaseLink = nullOrString(try JSONDict =>? "purchaseLink")
        
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
