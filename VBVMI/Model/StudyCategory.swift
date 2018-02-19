import Foundation
import CoreData
import Decodable

@objc(StudyCategory)
open class StudyCategory: _StudyCategory {
    
    class func decodeJSON(_ JSONDict: [AnyHashable : Any], context: NSManagedObjectContext) throws -> (StudyCategory) {
        
        guard let identifier : Any = JSONDict["id"] else {
            throw APIDataManagerError.missingID
        }
        
        let identifierString = "\(identifier)"
        
        guard let studyCategory = StudyCategory.findFirstWithDictionary(["identifier": identifierString], context: context) as? StudyCategory else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        studyCategory.identifier = identifierString
        studyCategory.order = try JSONDict => "order"
        studyCategory.name = try JSONDict => "name"
        
        // Leave the currently attached Studies as they are
        
        return studyCategory
    }
    
}
