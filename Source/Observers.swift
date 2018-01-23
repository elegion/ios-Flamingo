//
//  Observers.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 23.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public class ObserversArray<T> {

    private var weakPointers = [WeakWrapper]()

    public init() {

    }

    public func addObserver(observer: T) {
        weakPointers.append(WeakWrapper(value: observer as AnyObject))
    }

    public func removeObserver(observer: T) {

        for (index, delegateInArray) in weakPointers.enumerated() {
            if delegateInArray.value === (observer as AnyObject) {
                weakPointers.remove(at: index)
            }
        }
    }

    public func invoke(invocation: (T) -> Void) {
        for (_, observerPointer) in weakPointers.enumerated() {

            if let observer = observerPointer.value {
                // swiftlint:disable:next force_cast
                invocation(observer as! T)
            } else {
                if let indexToRemove = weakPointers.index(where: { $0 === observerPointer }) {
                    weakPointers.remove(at: indexToRemove)
                }
            }
        }
    }
}

private class WeakWrapper {
    weak var value: AnyObject?

    init(value: AnyObject) {
        self.value = value
    }
}
