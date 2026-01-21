//
//  YoutubePlayer.swift
//  Parkinsons
//
//  Created by Unnatti Gogna on 25/12/25.
//

import Foundation
import YouTubeiOSPlayerHelper

extension FullScreenYTPlayerView {
    
    
    func getParkinsonsFriendlyVars() -> [String: Any] {
        return [
            "controls": 0,
            "modestbranding": 1,
            "playsinline": 1,
            "rel": 0,
            "fs": 0,
            "iv_load_policy": 3,
            "disablekb": 1,
            "showinfo": 0,
            "autoplay": 1
        ]
    }
}
