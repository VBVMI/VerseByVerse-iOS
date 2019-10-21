import Foundation
import CoreData
import Decodable

extension String {
    func latinize() -> String {
        return self.folding(options: String.CompareOptions.diacriticInsensitive, locale: Locale.current)
    }
    
    func slugify(withSeparator separator: Character = "-") -> String {
        let slugCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\(separator)")
        
        return latinize().lowercased().components(separatedBy: slugCharacterSet.inverted).filter({ $0 != " " }).joined(separator: String(separator))
    }
}

struct APITopic : Decodable {
    var identifier: String
    var name: String
    
    enum CodingKeys: CodingKey, String {
        case identifier = "ID"
        case name = "topic"
    }
}

@objc(Topic)
open class Topic: _Topic {

    // Custom logic goes here.
    class func importTopic(_ object: APITopic, context: NSManagedObjectContext) throws -> (Topic?) {
        var convertedIdentifier = object.identifier.replacingOccurrences(of: "+", with: " ")
        convertedIdentifier = convertedIdentifier.slugify()
        if convertedIdentifier.count == 0 {
            return nil
        }
        
        if let name = object.name , name.count > 0 {
            let convertedName = name.capitalized
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
