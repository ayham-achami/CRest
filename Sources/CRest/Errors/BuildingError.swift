//
//  BuildingError.swift
//

import Foundation

/// Ошибка инициализации объекта моделей через билдер
public struct ModelBuildError: LocalizedError {

    /// Причина возникновения
    public let errorDescription: String
}
