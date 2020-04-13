//
//  APICoordinator.swift
//  VBVMI
//
//  Created by Thomas Carey on 4/04/20.
//  Copyright © 2020 Tom Carey. All rights reserved.
//

import Foundation

class APICoordinator {
    
    var livestreamRequestTimer: Timer?
    
    let backgroundQueue = DispatchQueue(label: "APICoordinator Queue")
    
    static let instance = APICoordinator()
    
    private init() {
    }
    
    func startPollingLivestream() {
        stopPollingLivestream()
        logger.info("🍕 Starting polling")
        let timer = Timer(fire: Date(), interval: 60, repeats: true, block: { [weak self] (timer) in
            logger.info("🍕 Firing request for livestreams")
            self?.backgroundQueue.async {
                APIDataManager.allTheLivestreams()
            }
        })
        RunLoop.main.add(timer, forMode: .default)
        livestreamRequestTimer = timer
    }
    
    func stopPollingLivestream() {
        guard let timer = livestreamRequestTimer else { return }
        logger.info("🍕 Stopping polling")
        timer.invalidate()
        livestreamRequestTimer = nil
    }
}
