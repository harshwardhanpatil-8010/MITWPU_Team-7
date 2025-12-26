//
//  FullScreenYTPlayerView.swift
//  Parkinsons
//
//  Created by SDC-USER on 07/12/25.
//

import UIKit
import YouTubeiOSPlayerHelper
import WebKit

class FullScreenYTPlayerView: YTPlayerView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Find the internal WebView and inject CSS to force "Full Frame"
        guard let web = subviews.first(where: { $0 is WKWebView }) as? WKWebView else { return }
        
        let js = """
            var css = `
            * { margin:0 !important; padding:0 !important; }
            html, body, #player, #player-container {
                width: 100% !important; height: 100% !important;
                background: black !important;
            }
            video {
                object-fit: cover !important; /* Maximizes therapist visibility */
            }
            .ytp-chrome-top, .ytp-chrome-bottom, .ytp-show-cards-title { 
                display: none !important; /* Hides distracting UI buttons */
            }
            `;
            var style = document.createElement('style');
            style.innerHTML = css;
            document.head.appendChild(style);
            """
        web.evaluateJavaScript(js, completionHandler: nil)
    }
}
