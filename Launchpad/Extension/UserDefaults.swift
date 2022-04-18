//
//  UserDefaults.swift
//  Launchpad
//
//  Created by Valere on 2022/4/14.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    private let publisher = PassthroughSubject<Value, Never>()
    
    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
            publisher.send(newValue)
        }
    }

    var projectedValue: AnyPublisher<Value, Never> {
        return publisher.eraseToAnyPublisher()
    }
}


extension UserDefaults {
    
    @UserDefault(key: "column_button_count", defaultValue: 3)
    static var columnButtonCount: Int
    
    @UserDefault(key: "row_button_count", defaultValue: 3)
    static var rowButtonCount: Int
}
