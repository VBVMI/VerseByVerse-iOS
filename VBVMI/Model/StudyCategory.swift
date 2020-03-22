import Foundation
import CoreData

struct APIStudyCategory : Decodable {
    var identifier: Int
    var order: Int32
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case order
        case name
    }
}

@objc(StudyCategory)
open class StudyCategory: _StudyCategory {
    
    class func importStudyCategory(_ object: APIStudyCategory, context: NSManagedObjectContext) throws -> (StudyCategory) {
        let identifierString = "\(object.identifier)"
        
        guard let studyCategory = StudyCategory.findFirstOrCreateWithDictionary(["identifier": identifierString], context: context) as? StudyCategory else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        studyCategory.identifier = identifierString
        studyCategory.order = object.order
        studyCategory.name = object.name
        
        // Leave the currently attached Studies as they are
        
        return studyCategory
    }
    
}
