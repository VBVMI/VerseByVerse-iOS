import Foundation

import CoreData

struct APILesson : Decodable {
    var identifier: String
    var postedDate: String
    var transcript: String?
    var transcriptHtmlURL: String?
    var url: String?
    var lessonNumber: String?
    var teacherAid: String?
    var index: Int?
    var videoSource: String?
    var title: String
    var topics: [APITopic]?
    var audioSource: String?
    var audioLength: String?
    var studentAid: String?
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "ID"
        case postedDate
        case transcript
        case transcriptHtmlURL = "transcript_html_url"
        case url
        case lessonNumber
        case teacherAid
        case index
        case videoSource
        case title
        case topics
        case audioSource
        case audioLength
        case studentAid
        case description
    }
}

@objc(Lesson)
open class Lesson: _Lesson {

	// Custom logic goes here.

    @discardableResult
    class func importLesson(_ object: APILesson, studyID: String, context: NSManagedObjectContext) throws -> Lesson {
        
        guard let lesson = Lesson.findFirstOrCreateWithDictionary(["identifier": object.identifier, "studyIdentifier": studyID], context: context) as? Lesson else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        lesson.identifier = object.identifier
        if let number = Double(object.postedDate) , object.postedDate.count > 0 {
            let date = Date(timeIntervalSince1970: number)
            lesson.postedDate = date
        }
        
        if let index = object.index {
            lesson.lessonIndex = Int32(index)
        }
        
        lesson.descriptionText = nullOrString(object.description?.stringByDecodingHTMLEntities)
        
        lesson.transcriptURL = nullOrString(object.transcript)
        lesson.transcriptHtmlURL = nullOrString(object.transcriptHtmlURL)
        lesson.url = nullOrString(object.url)
        
        lesson.teacherAid = nullOrString(object.teacherAid)
        
        lesson.title = object.title.stringByDecodingHTMLEntities
        
        lesson.videoSourceURL = nullOrString(object.videoSource)
        
        lesson.audioSourceURL = nullOrString(object.audioSource)
        
        lesson.isPlaceholder = lesson.audioSourceURL == nil
        
        lesson.audioLength = nullOrString(object.audioLength)
        lesson.studentAidURL = nullOrString(object.studentAid)
        lesson.studyIdentifier = studyID
        let decodedTitle = object.title.stringByDecodingHTMLEntities
        
        let (lessonParsedTitle, _) = TitleParser.components(decodedTitle)
        
        lesson.lessonTitle = lessonParsedTitle
        lesson.lessonNumber = nullOrString(object.lessonNumber)

        if let topicsArray = object.topics {
            //Then lets process the topics
            var myTopics = Set<Topic>()
            
            topicsArray.forEach({ (topicAPI) -> () in
                do {
                    if let topic = try Topic.importTopic(topicAPI, context: context) {
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
