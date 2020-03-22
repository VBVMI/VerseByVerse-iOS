import Foundation
import CoreData

struct APIEvents: Decodable {
    var events: [APIEvent]
}

struct APIEvent : Decodable {
    var identifier: String
    var thumbnailSource: String
    var map: String
    var eventDescription: String
    var thumbnailAltText: String
    var url: String?
    var eventDate: String?
    var eventTitle: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "ID"
        case thumbnailSource
        case map
        case eventDescription = "description"
        case thumbnailAltText
        case url
        case eventDate
        case eventTitle = "title"
    }
}

@objc(Event)
open class Event: _Event {

	// Custom logic goes here.
    class func importEvent(_ object: APIEvent, context: NSManagedObjectContext, index: Int) throws -> (Event) {
        guard let event = Event.findFirstOrCreateWithDictionary(["identifier": object.identifier], context: context) as? Event else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        event.identifier = object.identifier
        event.thumbnailSource = object.thumbnailSource
        event.map = object.map
        event.descriptionText = object.eventDescription.stringByDecodingHTMLEntities
        event.thumbnailAltText = nullOrString(object.thumbnailAltText)
        event.url = nullOrString(object.url)
        event.title = object.eventTitle.stringByDecodingHTMLEntities
        
        if let dateString = object.eventDate {
            if let date = DateFormatters.calendarDateFormatter.date(from: dateString) {
                let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let components = calendar.dateComponents([.day, .month, .year], from: date)
                event.eventDateComponents = components
            }
        }
        
        return event
    }

}
