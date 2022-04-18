//
//  UserDefaults.swift
//  Launchpad
//
//  Created by Valere on 2022/4/14.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<Value: Comparable> {
    let key: String
    let defaultValue: Value
    let maxValue: Value?
    var container: UserDefaults = .standard
    private let publisher = PassthroughSubject<Value, Never>()
    
    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            if let maxValue = maxValue, newValue > maxValue {
                return
            }
            container.set(newValue, forKey: key)
            publisher.send(newValue)
        }
    }

    var projectedValue: AnyPublisher<Value, Never> {
        return publisher.eraseToAnyPublisher()
    }
    
    init(key: String, defaultValue: Value, maxValue: Value? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.maxValue = maxValue
    }
}


extension UserDefaults {
    
    @UserDefault(key: "column_button_count", defaultValue: 3, maxValue: 4)
    static var columnButtonCount: Int
    
    @UserDefault(key: "row_button_count", defaultValue: 3, maxValue: 9)
    static var rowButtonCount: Int
}
