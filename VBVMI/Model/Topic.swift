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

@objc(Topic)
open class Topic: _Topic {

    // Custom logic goes here.
    class func decodeJSON(_ JSONDict: NSDictionary, context: NSManagedObjectContext) throws -> (Topic?) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        var convertedIdentifier = identifier.replacingOccurrences(of: "+", with: " ")
        convertedIdentifier = convertedIdentifier.slugify()
        if convertedIdentifier.characters.count == 0 {
            return nil
        }
        
        if let name = try JSONDict => "topic" as? String , name.characters.count > 0 {
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
