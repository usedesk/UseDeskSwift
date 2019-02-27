//
//  UDAudio.swift
//
//  Created by Сергей on 31/01/2019.
//

import AVFoundation
import RCAudioPlayer

class UDAudio: NSObject {

    class func duration(_ path: String?) -> Int? {
        //-------------------------------------------------------------------------------------------------------------------------------------------------
        let asset = AVURLAsset(url: URL(fileURLWithPath: path ?? ""), options: nil)
        let duration = Int(round(CMTimeGetSeconds(asset.duration)))
        return duration
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    class func playMessageIncoming() {
        //-------------------------------------------------------------------------------------------------------------------------------------------------
        let path = UDDir.application("rcmessage_incoming.aiff")
        RCAudioPlayer.shared().playSound(path)
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    class func playMessageOutgoing() {
        //-------------------------------------------------------------------------------------------------------------------------------------------------
        let path = UDDir.application("rcmessage_outgoing.aiff")
        RCAudioPlayer.shared().playSound(path)
    }
}
