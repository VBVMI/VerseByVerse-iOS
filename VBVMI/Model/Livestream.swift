import Foundation
import CoreData


struct APILivestreams: Decodable {
    var streams: [APILivestream]
}

struct APILivestream: Decodable {
    
    var videoId: String
    var title: String
    var expirationDate: String
    var postedDate: String
    var identifier: String
    
    enum CodingKeys: String, CodingKey {
        case postedDate
        case videoId
        case title
        case expirationDate
        case identifier = "id"
    }
}

@objc(Livestream)
open class Livestream: _Livestream {
	// Custom logic goes here.
    @discardableResult
    class func importLivestream(_ object: APILivestream, context: NSManagedObjectContext) throws -> Livestream {

        guard let livestream = Livestream.findFirstOrCreateWithDictionary(["identifier": object.identifier], context: context) as? Livestream else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        livestream.identifier = object.identifier
        livestream.title = object.title
        livestream.videoId = object.videoId
        if let number = Double(object.postedDate) , object.postedDate.count > 0 {
            let date = Date(timeIntervalSince1970: number)
            livestream.postedDate = date
        }
        
        if let number = Double(object.expirationDate), object.expirationDate.count > 0 {
            let date = Date(timeIntervalSince1970: number)
            livestream.expirationDate = date
        }

        return livestream
    }

}
