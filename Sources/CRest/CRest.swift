//
//  CRest.swift
//

import Foundation

// MARK: - String + Localized
extension String {
    
    /// Возвращает локализованную строку
    var localized: String {
        NSLocalizedString(self, comment: self)
    }

    /// Возвращает локализованную строку вставляя в ней заданные аргументы
    /// - Parameter arg: Аргументы
    /// - Returns:  Локализованную строку с аргументами
    func localized(args: CVarArg...) -> String {
        withVaList(args) { NSString(format: self.localized, arguments: $0) } as String
    }
}
