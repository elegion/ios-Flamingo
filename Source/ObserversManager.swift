//
//  ObserversManager.swift
//  Flamingo
//
//  Created by Andrey Nazarov on 24/11/2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public typealias VoidClosure = () -> Void

public protocol NetworkClientManageable {
    
    func process(input: VoidClosure?, output: VoidClosure?)
    var canProcess: Bool { get }
}

public struct NetworkClientObserverModel {
    var observer: NetworkClientManageable
    var priority: Int
    
    public init(observer: NetworkClientManageable, priority: Int) {
        self.observer = observer
        self.priority = priority
    }
}

open class ObserversManager {
    
    public var observersStorage: [NetworkClientObserverModel]? {
        didSet {
            observersStorage?.sort {
                return $0.priority > $1.priority
            }
        }
    }
    
    public func process(input: VoidClosure?, output: VoidClosure?) {
        if let observersStorage = observersStorage {
            
            for observerModel in observersStorage {
                if observerModel.observer.canProcess {
                    observerModel.observer.process(input: input, output: output)
                }
            }
            
        }
    }
    
}
