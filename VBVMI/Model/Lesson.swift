import Foundation

import CoreData
import Decodable

@objc(Lesson)
public class Lesson: _Lesson {

	// Custom logic goes here.

    class func decodeJSON(JSONDict: NSDictionary, studyID: String, context: NSManagedObjectContext, index: Int) throws -> Lesson {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.MissingID
        }
        guard let lesson = Lesson.findFirstOrCreateWithDictionary(["identifier": identifier, "studyIdentifier": studyID], context: context) as? Lesson else {
            throw APIDataManagerError.ModelCreationFailed
        }
        
        lesson.identifier = try JSONDict => "ID"
        let postedDateString: String = try JSONDict => "postedDate"
        if let number = Double(postedDateString) where postedDateString.characters.count > 0 {
            let date = NSDate(timeIntervalSince1970: number)
            lesson.postedDate = date
        }
        
        lesson.lessonIndex = Int32(index)
        
        let dateStudyGiven: String = try JSONDict => "dateStudyGiven"
        if let number = Double(dateStudyGiven) where dateStudyGiven.characters.count > 0 {
            let date = NSDate(timeIntervalSince1970: number)
            lesson.dateStudyGiven = date
        }
        let studyDescription: String = try JSONDict => "description"
        lesson.descriptionText = nullOrString(studyDescription.stringByDecodingHTMLEntities)
        
        lesson.transcriptURL = nullOrString(try JSONDict => "transcript")
        lesson.teacherAid = nullOrString(try JSONDict => "teacherAid")
        
        lesson.averageRating = nullOrString(try JSONDict => "averageRating")
        
        let lessonTitle: String = try JSONDict => "title"
        lesson.title = lessonTitle.stringByDecodingHTMLEntities
        
        lesson.videoSourceURL = nullOrString(try JSONDict => "averageRating")
        lesson.videoLength = nullOrString(try JSONDict => "videoLength")
        
        lesson.location = nullOrString(try JSONDict => "location")
        lesson.audioSourceURL = nullOrString(try JSONDict => "audioSource")
        lesson.audioLength = nullOrString(try JSONDict => "audioLength")
        lesson.studentAidURL = nullOrString(try JSONDict => "studentAid")
        lesson.studyIdentifier = studyID
        let decodedTitle = lessonTitle.stringByDecodingHTMLEntities
        
        let (lessonParsedTitle, lessonNumber) = TitleParser.components(decodedTitle)
        
        lesson.lessonTitle = lessonParsedTitle
        lesson.lessonNumber = lessonNumber

        if let topicsArray: [NSDictionary] = try JSONDict => "topics" as? [NSDictionary] {
            //Then lets process the topics
            var myTopics = Set<Topic>()
            
            topicsArray.forEach({ (topicJSONDict) -> () in
                do {
                    if let topic = try Topic.decodeJSON(topicJSONDict, context: context) {
                        myTopics.insert(topic)
                    }
                } catch let error {
                    log.error("Error decoding Topic \(error)... Skippping...")
                }
            })
            
            lesson.topics = myTopics
        }
        
        return lesson
    }
}

extension Lesson : AssetsDownloadable {
    func directory() -> NSURL? {
        if let url = AppDelegate.resourcesURL() {
            let fileURL = url.URLByAppendingPathComponent(studyIdentifier, isDirectory: true).URLByAppendingPathComponent(identifier, isDirectory: true)
            let fileManager = NSFileManager.defaultManager()
            if let path = fileURL.path where !fileManager.fileExistsAtPath(path) {
                do {
                    try fileManager.createDirectoryAtURL(fileURL, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    log.error("Error in lesson Directory: \(error)")
                    return nil
                }
            }
            return fileURL
        }
        return nil
    }
}
