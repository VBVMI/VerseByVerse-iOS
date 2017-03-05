import Foundation
import CoreData
import Decodable

@objc(Event)
open class Event: _Event {

	// Custom logic goes here.
    class func decodeJSON(_ JSONDict: NSDictionary, context: NSManagedObjectContext, index: Int) throws -> (Event) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.missingID
        }
        
        guard let event = Event.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Event else {
            throw APIDataManagerError.modelCreationFailed
        }
        
        event.identifier = try JSONDict => "ID"
        event.thumbnailSource = try JSONDict => "thumbnailSource"
        event.map = try JSONDict => "map"
        
        let eventDescription: String = try JSONDict => "description"
        event.descriptionText = eventDescription.stringByDecodingHTMLEntities
        event.thumbnailAltText = nullOrString(try JSONDict => "thumbnailAltText")
        event.url = nullOrString(try JSONDict => "url")
        
        if let dateString: String = try JSONDict => "eventDate" {
            if let date = DateFormatters.calendarDateFormatter.date(from: dateString) {
                let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let components = calendar.dateComponents([.day, .month, .year], from: date)
                event.eventDateComponents = components
            }
        }
        
        let eventTitle: String = try JSONDict => "title"
        event.title = eventTitle.stringByDecodingHTMLEntities
        
        return event
    }

}
