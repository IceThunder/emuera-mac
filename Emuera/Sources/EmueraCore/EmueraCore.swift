//
//  EmueraCore.swift
//  EmueraCore
//
//  Core module umbrella header
//  Created on 2025-12-18
//

/// Core Engine for Emuera Script Runtime
///
/// This module provides the fundamental script parsing and execution
/// capabilities for Emuera game engine, compatible with original Emuera
/// ERB/ERH script format.

@_exported import Foundation

// MARK: - Public API

// Common types
@_exported import struct EmueraCore.ScriptPosition
@_exported import enum EmueraCore.EmueraError
@_exported import class EmueraCore.Logger
@_exported import struct EmueraCore.Config
@_exported import struct EmueraCore.PathConfig

// Variable types
@_exported import class EmueraCore.VariableData
@_exported import enum EmueraCore.VariableType
@_exported import struct EmueraCore.VariableValue

// Script parsing
@_exported import class EmueraCore.ScriptParser
@_exported import struct EmueraCore.ScriptLine
@_exported import enum EmueraCore.TokenType

// Execution
@_exported import class EmueraCore.Engine
@_exported import class EmueraCore.ProcessState

// MARK: - Version Information

public let EmueraCoreVersion = "1.0.0"
public let EmueraVersion = "1.820" // Compatible with Emuera 1.820

// MARK: - Quick Access

/// Global logger instance for convenience
public func logDebug(_ message: String) {
    Logger.debug(message)
}

public func logInfo(_ message: String) {
    Logger.info(message)
}

public func logError(_ message: String) {
    Logger.error(message)
}