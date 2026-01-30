//
//  Timer.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//


import Foundation

protocol TimerModelDelegate: AnyObject {
    func timerDidUpdate(timeLeft: Int, progress: CGFloat)
    func timerDidFinish()
}

final class TimerModel {
    
    weak var delegate: TimerModelDelegate?
    
    private var timer: Timer?
    private(set) var totalTime: Int
    private(set) var timeLeft: Int
    
    var isPaused = false
    
    init(totalSeconds: Int, startWithTimeLeft: Int? = nil) {
        self.totalTime = totalSeconds
//        self.timeLeft = totalSeconds
        self.timeLeft = startWithTimeLeft ?? totalSeconds
    }
    
    func start() {
        if timer != nil { return }
        runTimer()
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        isPaused = true
    }
    
    func resume() {
        guard isPaused else { return }
        isPaused = false
        runTimer()
    }
    
    private func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.tick()
        }
    }
    
    private func tick() {
        guard timeLeft > 0 else {
            timer?.invalidate()
            delegate?.timerDidFinish()
            return
        }
        
        timeLeft -= 1
        
        let progress = CGFloat(timeLeft) / CGFloat(totalTime)
        delegate?.timerDidUpdate(timeLeft: timeLeft, progress: progress)
    }
}
