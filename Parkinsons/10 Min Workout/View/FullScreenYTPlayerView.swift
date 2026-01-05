//
//  FullScreenYTPlayerView.swift
//  Parkinsons
//
//  Created by SDC-USER on 07/12/25.
//

import UIKit
import YouTubeiOSPlayerHelper

class FullScreenYTPlayerView: YTPlayerView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       
        guard let web = subviews.first(where: { $0 is WKWebView }) as? WKWebView else {
            return
        }
        
        let js = """
            var css = `
            * { margin:0 !important; padding:0 !important; }
            html, body, #player, #player-container, .html5-video-container, .video-stream {
                position: absolute !important;
                top: 0 !important;
                left: 0 !important;
                width: 100% !important;
                height: 100% !important;
                overflow: hidden !important;
                background: black !important;
            }
            video {
                position: absolute !important;
                top: 0 !important;
                left: 0 !important;
                width: 100% !important;
                height: 100% !important;
                object-fit: cover !important;
            }
            iframe {
                position: absolute !important;
                width: 100% !important;
                height: 100% !important;
                top: 0 !important;
                left: 0 !important;
            }
            `;
            var style = document.createElement('style');
            style.innerHTML = css;
            document.head.appendChild(style);
            """
        web.evaluateJavaScript(js, completionHandler: nil)
    }

}
