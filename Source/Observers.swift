//
//  Observers.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 23.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

internal class ObserversArray<T> {

    private var weakPointers = [WeakWrapper]()

    internal init() {

    }

    internal func addObserver(observer: T) {
        weakPointers.append(WeakWrapper(value: observer as AnyObject))
    }

    internal func removeObserver(observer: T) {

        for (index, delegateInArray) in weakPointers.enumerated() {
            if delegateInArray.value === (observer as AnyObject) {
                weakPointers.remove(at: index)
            }
        }
    }

    internal func iterate(invocation: (T, Int) -> Void) {
        for (i, observerPointer) in weakPointers.enumerated() {

            if let observer = observerPointer.value {
                // swiftlint:disable:next force_cast
                invocation(observer as! T, i)
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
