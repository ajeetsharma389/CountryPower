import Foundation
import MapKit
/*
 This class is used for making of annotation view like pin on Map
 */
class  CallOutView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        
        willSet {
            guard let annotationView = newValue as? PollutionAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            image = UIImage(named: "pin")
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = annotationView.pollutionIndexString
            detailCalloutAccessoryView = detailLabel
        }
    }
}

