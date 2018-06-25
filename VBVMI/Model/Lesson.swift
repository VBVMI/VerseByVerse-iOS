import Foundation

import CoreData
import Decodable

@objc(Lesson)
open class Lesson: _Lesson {

	// Custom logic goes here.

    @discardableResult
    class func decodeJSON(_ JSONDict: [AnyHashable : Any], studyID: String, context: NSManagedObjectContext) throws -> Lesson {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        guard let lesson = Lesson.findFirstOrCreateWithDictionary(["identifier": identifier, "studyIdentifier": studyID], context: context) as? Lesson else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        lesson.identifier = try JSONDict => "ID"
        let postedDateString: String = try JSONDict => "postedDate"
        if let number = Double(postedDateString) , postedDateString.count > 0 {
            let date = Date(timeIntervalSince1970: number)
            lesson.postedDate = date
        }
        
        lesson.lessonIndex = try JSONDict => "index"
        
        let studyDescription: String = try JSONDict => "description"
        lesson.descriptionText = nullOrString(studyDescription.stringByDecodingHTMLEntities)
        
        lesson.transcriptURL = nullOrString(try JSONDict => "transcript")
        lesson.teacherAid = nullOrString(try JSONDict => "teacherAid")
        
        let lessonTitle: String = try JSONDict => "title"
        lesson.title = lessonTitle.stringByDecodingHTMLEntities
        
        lesson.videoSourceURL = nullOrString(try JSONDict => "videoSource")
        
        lesson.audioSourceURL = nullOrString(try JSONDict => "audioSource")
        
        lesson.isPlaceholder = lesson.audioSourceURL == nil
        
        lesson.audioLength = nullOrString(try JSONDict => "audioLength")
        lesson.studentAidURL = nullOrString(try JSONDict => "studentAid")
        lesson.studyIdentifier = studyID
        let decodedTitle = lessonTitle.stringByDecodingHTMLEntities
        
        let (lessonParsedTitle, _) = TitleParser.components(decodedTitle)
        
        lesson.lessonTitle = lessonParsedTitle
        lesson.lessonNumber = nullOrString(try JSONDict => "lessonNumber")

        if let topicsArray: [[AnyHashable: Any]] = try JSONDict => "topics" as? [[AnyHashable: Any]] {
            //Then lets process the topics
            var myTopics = Set<Topic>()
            
            topicsArray.forEach({ (topicJSONDict) -> () in
                do {
                    if let topic = try Topic.decodeJSON(topicJSONDict, context: context) {
                        myTopics.insert(topic)
                    }
                } catch let error {
                    logger.error("Error decoding Topic \(error)... Skippping...")
                }
            })
            
            lesson.topics = myTopics
        }
        
        return lesson
    }
}

extension Lesson : AssetsDownloadable {
    func directory() -> URL? {
        if let url = AppDelegate.resourcesURL() {
            let fileURL = url.appendingPathComponent(studyIdentifier, isDirectory: true).appendingPathComponent(identifier, isDirectory: true)
            let fileManager = FileManager.default
            let path = fileURL.path
            if !fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    logger.error("Error in lesson Directory: \(error)")
                    return nil
                }
            }
            return fileURL
        }
        return nil
    }
}
