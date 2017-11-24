//
//  ObserversManager.swift
//  Flamingo
//
//  Created by Andrey Nazarov on 24/11/2017.
//  Copyright © 2017 ELN. All rights reserved.
//

import Foundation

public protocol NetworkClientManageable {

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
    
}
