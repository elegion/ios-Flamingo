//
//  ObserversManager.swift
//  Flamingo
//
//  Created by Andrey Nazarov on 24/11/2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public typealias NetworkClientManageable = NetworkClientLoggable&NetworkClientMapable

public protocol NetworkClientLoggable {
    
    func manageLog(response: Result<AnyObject>?)
    
}

public protocol NetworkClientMapable {
    
    func mapResponse() -> Result<AnyObject>?
    
}

public enum NetworkClientObserverType {
    
    case undefined
    case logger
    case mapper
    
}

public struct NetworkClientObserverModel {
    var observer: NetworkClientManageable
    var priority: Int
    var type: NetworkClientObserverType
    
    public init(observer: NetworkClientManageable, type: NetworkClientObserverType, priority: Int) {
        self.observer = observer
        self.priority = priority
        self.type = type
    }
}

open class ObserversManager {
    
    private var isPrepared = false
    
    public var observersStorage: [NetworkClientObserverModel] = [] {
        didSet {
            isPrepared = false
        }
    }
    
    private var loggersStorage: [NetworkClientObserverModel] = []
    private var mappersStorage: [NetworkClientObserverModel] = []
    
    public func process() -> Result<AnyObject>? {
        prepareForManageIfNeeded()
        
        var mappingResult: Result<AnyObject>?
        for mapper in mappersStorage {
            mappingResult = mapper.observer.mapResponse()
            
            if mappingResult != nil {
                break
            }
        }
        
        for logger in loggersStorage {
            logger.observer.manageLog(response: mappingResult)
        }
            
        
        return mappingResult
    }
    
    private func prepareForManageIfNeeded() {
        guard !isPrepared else {
            return
        }
        
        loggersStorage = observersStorage.filter({
            $0.type == .logger
        }).sorted {
            (lhs, rhs) in
            
            lhs.priority < rhs.priority
        }
        
        mappersStorage = observersStorage.filter({
            $0.type == .mapper
        }).sorted {
            (lhs, rhs) in
            
            lhs.priority < rhs.priority
        }
        
        isPrepared = true
    }
    
}
