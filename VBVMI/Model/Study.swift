import Foundation
import CoreData

struct APICore: Decodable {
    var studies: [APIStudy]
}

struct APIStudy: Decodable {
    var identifier: String
    var thumbnailSource: String
    var descriptionText: String
    var thumbnailAltText: String?
    var category: String?
    var bibleIndex: Int
    var title: String
    var podcastLink: String?
    var lessonCount: String
    var url: String?
    var image160: String?
    var image300: String?
    var image600: String?
    var image900: String?
    var image1100: String?
    var image1400: String?
    
    var topics: [APITopic]?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "ID"
        case thumbnailSource
        case descriptionText = "description"
        case thumbnailAltText
        case category
        case bibleIndex
        case title
        case podcastLink
        case lessonCount
        case url
        case image160
        case image300
        case image600
        case image900
        case image1100
        case image1400
        case topics
    }
}

@objc(Study)
open class Study: _Study {

	// Custom logic goes here.
    class func importStudy(_ object: APIStudy, context: NSManagedObjectContext, index: Int) throws -> (Study) {
        guard let study = Study.findFirstOrCreateWithDictionary(["identifier": object.identifier], context: context) as? Study else {
            throw APIDataManagerError.modelCreationFailed
        }

        study.identifier = object.identifier
        study.thumbnailSource = object.thumbnailSource
        study.studyIndex = Int32(index)
    
        study.descriptionText = object.descriptionText
        study.thumbnailAltText = nullOrString(object.thumbnailAltText)
        study.category = "\(object.category ?? "0")" // Catedory identifier needs to be a string
        
        study.studyCategory = StudyCategory.findFirstWithPredicate(NSPredicate(format: "identifier MATCHES %@", study.category), context: context)
        
        study.bibleIndex = Int32(object.bibleIndex)
        
        let studyTitle: String = object.title
        study.title = studyTitle.stringByDecodingHTMLEntities
        
        study.podcastLink = nullOrString(object.podcastLink)
        
        let lessonCount: String = object.lessonCount
        study.lessonCount = Int32(lessonCount) ?? study.lessonCount
        study.url = nullOrString(object.url)
        
        study.image160 = nullOrString(object.image160)
        study.image300 = nullOrString(object.image300)
        study.image600 = nullOrString(object.image600)
        study.image900 = nullOrString(object.image900)
        study.image1100 = nullOrString(object.image1100)
        study.image1400 = nullOrString(object.image1400)
        
        if let topicsArray = object.topics {
            //Then lets process the topics
            var myTopics = Set<Topic>()
            
            topicsArray.forEach({ (topicObject) -> () in
                do {
                    if let topic = try Topic.importTopic(topicObject, context: context) {
                        myTopics.insert(topic)
                    }
                } catch let error {
                    logger.error("Error decoding Topic \(error)... Skippping...")
                }
            })
            
            study.topics = myTopics
        }
        
        return study
    }

}
