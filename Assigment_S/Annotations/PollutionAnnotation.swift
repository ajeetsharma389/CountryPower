import Foundation
import MapKit
/*
 This class is used for making of annotation / popview which gets as pop on click of annotation pin
 */

class PollutionAnnotation: NSObject, MKAnnotation {
    let title: String?
    let pollutionIndexString : String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, pollutionIndexString: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        
        self.coordinate = coordinate
        self.pollutionIndexString = pollutionIndexString//"Varying for traits is great for making more significant"
        super.init()
    }
}
