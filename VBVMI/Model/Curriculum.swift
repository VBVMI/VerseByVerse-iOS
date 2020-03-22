import Foundation
import CoreData

struct APICurriculums: Decodable {
    var channels: [APICurriculum]
}

struct APICurriculum : Decodable {
    var identifier: String
    var pdfURL: String
    var postedDate: TimeInterval?
    var title: String
    var url: String?
    var coverImage: String?
    var purchaseLink: String?
    var videos: [APIVideo]?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "ID"
        case pdfURL = "pdf"
        case postedDate
        case title
        case url
        case coverImage = "cover_image"
        case purchaseLink
        case videos
    }
}

@objc(Curriculum)
open class Curriculum: _Curriculum {
	// Custom logic goes here.
    
    class func importCurriculum(_ object: APICurriculum, context: NSManagedObjectContext, index: Int) throws -> (Curriculum) {
        guard let channel = Curriculum.findFirstOrCreateWithDictionary(["identifier": object.identifier], context: context) as? Curriculum else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        channel.identifier = object.identifier
        channel.pdfURL = object.pdfURL
        
        if let dateString = object.postedDate {
            channel.postedDate = Date(timeIntervalSince1970: dateString)
        }
        
        channel.title = object.title.stringByDecodingHTMLEntities
        
        channel.url = nullOrString(object.url)
        channel.coverImage = nullOrString(object.coverImage)
        
        channel.purchaseLink = nullOrString(object.purchaseLink)
        
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
