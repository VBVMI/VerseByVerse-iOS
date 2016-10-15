import Foundation
import CoreData
import Decodable
//import SwiftString

@objc(Topic)
open class Topic: _Topic {

    // Custom logic goes here.
    class func decodeJSON(_ JSONDict: NSDictionary, context: NSManagedObjectContext) throws -> (Topic?) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        var convertedIdentifier = identifier.clean(with: " ", allOf: "+")
        convertedIdentifier = convertedIdentifier.slugify()
        if convertedIdentifier.characters.count == 0 {
            return nil
        }
        
        if let name = try JSONDict => "topic" as? String , name.characters.count > 0 {
            let convertedName = name.capitalize()
            guard let topic = Topic.findFirstOrCreateWithDictionary(["identifier": convertedIdentifier], context: context) as? Topic else {
                throw APIDataManagerError.modelCreationFailed
            }
            topic.identifier = convertedIdentifier
            topic.name = convertedName
            return topic
        }
        
        return nil
    }

}
