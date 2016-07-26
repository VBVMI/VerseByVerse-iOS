import Foundation
import CoreData
import Decodable

@objc(Event)
public class Event: _Event {

	// Custom logic goes here.
    class func decodeJSON(JSONDict: NSDictionary, context: NSManagedObjectContext, index: Int) throws -> (Event) {
        guard let identifier = JSONDict["ID"] as? String else {
            throw APIDataManagerError.MissingID
        }
        
        guard let event = Event.findFirstOrCreateWithDictionary(["identifier": identifier], context: context) as? Event else {
            throw APIDataManagerError.ModelCreationFailed
        }
        
        event.identifier = try JSONDict => "ID"
        event.thumbnailSource = try JSONDict => "thumbnailSource"
        event.map = try JSONDict => "map"
        
        let eventDescription: String = try JSONDict => "description"
        event.descriptionText = eventDescription.stringByDecodingHTMLEntities
        event.thumbnailAltText = nullOrString(try JSONDict => "thumbnailAltText")
        
        if let dateString: String = try JSONDict => "eventDate" {
            if let date = DateFormatters.calendarDateFormatter.dateFromString(dateString), let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) {
                
                let components = calendar.components([.Day, .Month, .Year], fromDate: date)
                event.eventDateComponents = components
            }
        }
        
        let eventTitle: String = try JSONDict => "title"
        event.title = eventTitle.stringByDecodingHTMLEntities
        
        return event
    }

}
