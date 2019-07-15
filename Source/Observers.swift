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

    private enum StorageType {
        case weak(WeakWrapper)
        case strong(T)
    }

    private var pointers = [StorageType]()

    internal init() {

    }

    internal func addObserver(observer: T, storagePolicy: StoragePolicy = .weak) {
        let storageItem: StorageType
        switch storagePolicy {
        case .weak:
            storageItem = .weak(WeakWrapper(value: observer as AnyObject))
        case .strong:
            storageItem = .strong(observer)
        }
        pointers.append(storageItem)
    }

    internal func removeObserver(observer: T) {
        let findClosure = {
            (item: StorageType) -> Bool in

            switch item {
            case .weak(let wrapper):
                return wrapper.value === (observer as AnyObject)
            case .strong(let pointer):
                return (pointer as AnyObject) === (observer as AnyObject)
            }
        }
        if let index = pointers.firstIndex(where: findClosure) {
            pointers.remove(at: index)
        }
    }

    internal func iterate(invocation: (T, Int) -> Void) {
        for (i, storageItem) in pointers.enumerated() {

            switch storageItem {
            case .strong(let pointer):
                invocation(pointer, i)
            case .weak(let wrapper):
                if let observer = wrapper.value {
                    // swiftlint:disable:next force_cast
                    invocation(observer as! T, i)
                } else {
                    pointers.remove(at: i)
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
