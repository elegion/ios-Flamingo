//
//  Observers.swift
//  Flamingo
//
//  Created by Nikolay Ischuk on 23.01.2018.
//  Copyright © 2018 ELN. All rights reserved.
//

import Foundation

public enum StoragePolicy {
    case weak
    case strong
}

internal class ObserversArray<T> {

    private var weakPointers = [WeakWrapper]()
    private var strongPointers = [T]()

    internal init() {

    }

    internal func addObserver(observer: T, storagePolicy: StoragePolicy = .weak) {
        switch storagePolicy {
        case .weak:
            weakPointers.append(WeakWrapper(value: observer as AnyObject))
        case .strong:
            strongPointers.append(observer)
        }
    }

    internal func removeObserver(observer: T) {
        if let index = weakPointers.index(where: { $0.value === (observer as AnyObject) }) {
            weakPointers.remove(at: index)
        }

        if let index = strongPointers.index(where: { ($0 as AnyObject) === (observer as AnyObject) }) {
            strongPointers.remove(at: index)
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

        for (i, observer) in strongPointers.enumerated() {
            invocation(observer, i + weakPointers.count)
        }
    }
}

private class WeakWrapper {
    weak var value: AnyObject?

    init(value: AnyObject) {
        self.value = value
    }
}
