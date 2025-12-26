//
//  YoutubePlayer.swift
//  Parkinsons
//
//  Created by Unnatti Gogna on 25/12/25.
//

import Foundation
import YouTubeiOSPlayerHelper

extension FullScreenYTPlayerView {
    
    /// Provides a dictionary of settings optimized for users with Parkinson's.
    /// This removes distracting UI elements and prevents accidental navigation.
    func getParkinsonsFriendlyVars() -> [String: Any] {
        return [
            "controls": 0,             // Hide playback controls (prevent accidental taps)
            "modestbranding": 1,       // Hide YouTube logo
            "playsinline": 1,          // Play inside the app, not full screen
            "rel": 0,                  // Don't show related videos at the end
            "fs": 0,                   // Disable full-screen button
            "iv_load_policy": 3,       // Hide video annotations
            "disablekb": 1,            // Disable keyboard shortcuts
            "showinfo": 0,             // Hide video title and uploader
            "autoplay": 1              // Start immediately to reduce user friction
        ]
    }
}
