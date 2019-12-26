//
//  RCMessage.swift

import Foundation
import MapKit

class RCFile: NSObject {
    var type = ""
    var name = ""
    var content = ""
    var size = ""
}

public class RCMessage: NSObject {
    // MARK: - Properties
    var type: Int = 0
    var incoming = false
    var outgoing = false
    var feedback = false
    var text = ""
    var rcButtons = [RCMessageButton]()
    var picture_image: UIImage?
    var picture_width: Int = 0
    var picture_height: Int = 0
    var video_path = ""
    var video_thumbnail: UIImage?
    var video_duration: Int = 0
    var audio_path = ""
    var audio_duration: Int = 0
    var audio_status: Int = 0
    var date: Date?
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    var location_thumbnail: UIImage?
    var status: Int = 0
    var chat: Int = 0
    var messageId: Int = 0
    var ticket_id: Int = 0
    var createdAt = ""
    var name = ""
    var avatar = ""
    var file: RCFile?
    
    // MARK: - Initialization methods
    init(status text: String?) {
        super.init()
        type = RC_TYPE_STATUS
        
        incoming = false
        outgoing = false
        feedback = false
        
        self.text = text ?? ""
    }
    
    init(text: String?, incoming: Bool) {
        super.init()
        
        type = RC_TYPE_TEXT
        
        self.incoming = incoming
        outgoing = !incoming
        feedback = false
        
        self.text = text ?? ""
    }
    
    init(emoji text: String?, incoming: Bool) {
        super.init()
        
        type = RC_TYPE_EMOJI
        
        self.incoming = incoming
        outgoing = !incoming
        
        self.text = text ?? ""
    }
    
    init(picture image: UIImage?, width: Int, height: Int, incoming: Bool) {
        super.init()
        
        type = RC_TYPE_PICTURE
        
        self.incoming = incoming
        outgoing = !incoming
        feedback = false
        
        picture_image = image
        picture_width = width
        picture_height = height
    }
    
    init(video path: String?, durarion duration: Int, incoming: Bool) {
        super.init()
        
        type = RC_TYPE_VIDEO
        
        self.incoming = incoming
        outgoing = !incoming
        
        video_path = path != nil ? path! : ""
        video_duration = duration
    }
    
    init(audio path: String?, durarion duration: Int, incoming: Bool) {
        super.init()
        
        type = RC_TYPE_AUDIO
        
        self.incoming = incoming
        outgoing = !incoming
        
        audio_path = path != nil ? path! : ""
        audio_duration = duration
        audio_status = RC_AUDIOSTATUS_STOPPED
    }
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, incoming: Bool, completion: @escaping () -> Void) {
        super.init()
        
        type = RC_TYPE_LOCATION
        
        self.incoming = incoming
        outgoing = !incoming
        
        self.latitude = latitude
        self.longitude = longitude
        
        status = RC_STATUS_LOADING
        
        var region = MKCoordinateRegion()
        region.center.latitude = latitude
        region.center.longitude = longitude
        region.span.latitudeDelta = CLLocationDegrees(0.005)
        region.span.longitudeDelta = CLLocationDegrees(0.005)
        
        let options = MKMapSnapshotOptions()
        options.region = region
        options.size = CGSize(width: RCMessages.locationBubbleWidth(), height: RCMessages.locationBubbleHeight())
        options.scale = UIScreen.main.scale
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start(with: DispatchQueue.global(qos: .default), completionHandler: { [weak self] snapshot, error in
            guard let wSelf = self else {return}
            if snapshot != nil {
                UIGraphicsBeginImageContextWithOptions((snapshot?.image.size)!, true, (snapshot?.image.scale)!)
                do {
                    snapshot?.image.draw(at: CGPoint.zero)
                    
                    let pin: MKAnnotationView? = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                    var point: CGPoint? = snapshot?.point(for: CLLocationCoordinate2DMake(wSelf.latitude, wSelf.longitude))
                    point?.x += (pin?.centerOffset.x ?? 0.0) - ((pin?.bounds.size.width ?? 0.0) / 2)
                    point?.y += (pin?.centerOffset.y ?? 0.0) - ((pin?.bounds.size.height ?? 0.0) / 2)
                    pin?.image?.draw(at: point ?? CGPoint.zero)
                    
                    wSelf.location_thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                }
                UIGraphicsEndImageContext()
                
                wSelf.status = RC_STATUS_SUCCEED
                DispatchQueue.main.async(execute: {
                        completion()
                })
            }
        })
    }
}
