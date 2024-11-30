//
//  ConnectionManager.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 30/11/24.
//

import Foundation
import Network
import Combine

extension Notification.Name {
    static let connectionChanged = Notification.Name("ConnectionChanged")
}

class ConnectivityMonitor {
    
    private var monitor: NWPathMonitor?
    private var queue: DispatchQueue
    
    private let connectivitySubject = PassthroughSubject<Bool, Never>()
    
    var connectivityPublisher: AnyPublisher<Bool, Never> {
        return connectivitySubject.eraseToAnyPublisher()
    }
    
    init() {
        self.queue = DispatchQueue(label: "NetworkMonitorQueue")
        startMonitoring()
    }
    
    // Start monitoring network changes
    private func startMonitoring() {
        monitor = NWPathMonitor()
        
        // Start monitoring on the background queue
        monitor?.start(queue: queue)
        
        // Monitor for network changes
        monitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.connectivitySubject.send(path.status == .satisfied)
            }
        }
    }
    
    // Stop monitoring when no longer needed
    func stopMonitoring() {
        monitor?.cancel()
    }
}
