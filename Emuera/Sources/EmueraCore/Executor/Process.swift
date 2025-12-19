//
//  Process.swift
//  Emuera
//
//  Process Management and Function Call Stack
//  Based on C# Emuera Process.cs and Process.State.cs
//
//  简化版本 - 只包含核心的函数调用栈管理
//

import Foundation

// MARK: - System State Code
/// System state management (similar to C# SystemStateCode)
public enum SystemStateCode: Int {
    case titleBegin = 0
    case normal = 0xFFFF

    // Helper flags
    static let canBegin: Int = 0x20000

    func canBegin() -> Bool {
        return (self.rawValue & SystemStateCode.canBegin) != 0
    }
}

// MARK: - Begin Type
public enum BeginType: String {
    case null = "NULL"
    case shop = "SHOP"
    case train = "TRAIN"
    case afterTrain = "AFTERTRAIN"
    case ablup = "ABLUP"
    case turnend = "TURNEND"
    case first = "FIRST"
    case title = "TITLE"
}

// MARK: - Called Function
/// Represents a function call in the call stack
public final class CalledFunction {
    public let functionName: String
    public private(set) var currentLabel: FunctionLabelLine?
    public private(set) var topLabel: FunctionLabelLine?
    public var returnAddress: LogicalLine?
    public var isJump: Bool = false
    public var isEvent: Bool = false

    // For event functions with multiple implementations
    private var eventLabelList: [[FunctionLabelLine]]?
    private var counter: Int = -1
    private var group: Int = 0

    private init(functionName: String) {
        self.functionName = functionName
    }

    /// Create a regular function call
    public static func callFunction(_ label: String, _ retAddress: LogicalLine?, _ labelDictionary: LabelDictionary) -> CalledFunction? {
        let called = CalledFunction(functionName: label)

        guard let labelLine = labelDictionary.getNonEventLabel(label) else {
            // Check if it's an event label (error case)
            if labelDictionary.getEventLabels(label) != nil {
                return nil  // Event function called with CALL
            }
            return nil
        }

        // Check method type mismatch
        if labelLine.isMethod {
            return nil  // Function method called with CALL
        }

        called.topLabel = labelLine
        called.currentLabel = labelLine
        called.returnAddress = retAddress
        called.isEvent = false

        return called
    }

    /// Create an event function call
    public static func callEventFunction(_ label: String, _ retAddress: LogicalLine?, _ labelDictionary: LabelDictionary) -> CalledFunction? {
        let called = CalledFunction(functionName: label)

        guard let eventLabels = labelDictionary.getEventLabels(label) else {
            // Check if it's a non-event label (error case)
            if labelDictionary.getNonEventLabel(label) != nil {
                return nil  // Non-event function called with EVENT
            }
            return nil
        }

        called.eventLabelList = eventLabels.map { [$0] }  // Wrap in array for consistency
        called.counter = -1
        called.group = 0
        called.isEvent = true
        called.returnAddress = retAddress
        called.shiftNext()
        called.topLabel = called.currentLabel

        return called
    }

    /// Create a function method (for #FUNCTION)
    public static func createFunctionMethod(_ labelLine: FunctionLabelLine, _ label: String) -> CalledFunction {
        let called = CalledFunction(functionName: label)
        called.topLabel = labelLine
        called.currentLabel = labelLine
        called.returnAddress = nil
        called.isEvent = false
        return called
    }

    /// Shift to next implementation (for event functions)
    public func shiftNext() {
        while true {
            counter += 1
            if let list = eventLabelList, group < list.count, counter < list[group].count {
                currentLabel = list[group][counter]
                return
            }
            group += 1
            counter = -1
            if group >= 4 {
                currentLabel = nil
                return
            }
        }
    }

    /// Shift to next group (for #SINGLE flag)
    public func shiftNextGroup() {
        counter = -1
        group += 1
        if group >= 4 {
            currentLabel = nil
            return
        }
        shiftNext()
    }

    /// Finish event completely
    public func finishEvent() {
        group = 4
        counter = -1
        currentLabel = nil
    }

    public var hasSingleFlag: Bool {
        return currentLabel?.isSingle ?? false
    }

    public var isOnly: Bool {
        return currentLabel?.isOnly ?? false
    }

    public var finished: Bool {
        return currentLabel == nil
    }

    public var returnAddressLine: LogicalLine? {
        return returnAddress
    }

    public func updateRetAddress(_ line: LogicalLine) {
        returnAddress = line
    }

    public func callLabel(_ label: String, _ currentLabel: FunctionLabelLine?, _ labelDictionary: LabelDictionary) -> LogicalLine? {
        return labelDictionary.getLabelDollar(label, currentLabel)
    }

    public func clone() -> CalledFunction {
        let called = CalledFunction(functionName: self.functionName)
        called.eventLabelList = self.eventLabelList
        called.currentLabel = self.currentLabel
        called.topLabel = self.topLabel
        called.group = self.group
        called.isEvent = self.isEvent
        called.counter = self.counter
        called.returnAddress = self.returnAddress
        return called
    }
}

// MARK: - Process State
/// Manages execution state and call stack
public final class ProcessState {
    private var functionList: [CalledFunction] = []
    private var _currentLine: LogicalLine?
    public var lineCount: Int = 0
    public var currentMin: Int = 0  // For function methods

    private var sysStateCode: SystemStateCode = .titleBegin
    private var beginType: BeginType = .null
    private var isClone: Bool = false

    public init() {}

    // MARK: - Properties

    public var scriptEnd: Bool {
        return functionList.count == currentMin
    }

    public var functionCount: Int {
        return functionList.count
    }

    public var currentLine: LogicalLine? {
        get { return _currentLine }
        set { _currentLine = newValue }
    }

    public var errorLine: LogicalLine? {
        return currentLine
    }

    public var currentCalled: CalledFunction? {
        guard !functionList.isEmpty else { return nil }
        return functionList.last
    }

    public var systemState: SystemStateCode {
        get { return sysStateCode }
        set { sysStateCode = newValue }
    }

    public var isBegun: Bool {
        return beginType != .null
    }

    public var scope: String? {
        guard !functionList.isEmpty else { return nil }
        return functionList.last?.functionName
    }

    public var isFunctionMethod: Bool {
        guard currentMin < functionList.count else { return false }
        return functionList[currentMin].topLabel?.isMethod ?? false
    }

    // MARK: - Line Navigation

    public func shiftNextLine() {
        currentLine = currentLine?.nextLine
        lineCount += 1
    }

    public func jumpTo(_ line: LogicalLine) {
        currentLine = line
        lineCount += 1
    }

    // MARK: - Begin Operations

    public func setBegin(_ keyword: String) {
        switch keyword.uppercased() {
        case "SHOP": setBegin(.shop)
        case "TRAIN": setBegin(.train)
        case "AFTERTRAIN": setBegin(.afterTrain)
        case "ABLUP": setBegin(.ablup)
        case "TURNEND": setBegin(.turnend)
        case "FIRST": setBegin(.first)
        case "TITLE": setBegin(.title)
        default: break
        }
    }

    public func setBegin(_ type: BeginType) {
        // Check if BEGIN is allowed in current state
        if type != .title && !sysStateCode.canBegin() {
            return
        }

        beginType = type
    }

    public func begin() {
        if sysStateCode == .normal {
            // Special handling when calling begin from normal state
        }

        switch beginType {
        case .shop: sysStateCode = .normal
        case .train: sysStateCode = .normal
        case .afterTrain: sysStateCode = .normal
        case .ablup: sysStateCode = .normal
        case .turnend: sysStateCode = .normal
        case .first: sysStateCode = .normal
        case .title: sysStateCode = .titleBegin
        case .null: return
        }

        // Clear all functions
        functionList.removeAll()
        beginType = .null
    }

    public func beginDirect(_ type: BeginType) {
        beginType = type
        sysStateCode = .titleBegin
        begin()
    }

    // MARK: - Return Management

    public func `return`(_ ret: Int64) throws {
        if isFunctionMethod {
            try returnF(nil)
            return
        }

        guard var called = functionList.last else {
            // Return from top-level
            if beginType != .null {
                begin()
            }
            return
        }

        if called.isJump {
            // JUMP immediately returns
            functionList.removeLast()
            try `return`(ret)
            return
        }

        if !called.isEvent {
            currentLine = nil
        } else {
            if called.isOnly {
                called.finishEvent()
            } else if called.hasSingleFlag && ret == 1 {
                called.shiftNextGroup()
            } else {
                called.shiftNext()
            }

            currentLine = called.currentLabel
            if let label = called.currentLabel {
                lineCount += 1
            }
        }

        // Function end
        if currentLine == nil {
            currentLine = called.returnAddress
            functionList.removeLast()
            if currentLine == nil {
                if beginType != .null {
                    begin()
                }
                return
            }
            lineCount += 1
            return
        }

        lineCount += 1
    }

    public func returnF(_ ret: Any?) throws {
        guard !functionList.isEmpty else {
            return
        }

        currentLine = functionList.last?.returnAddress
        functionList.removeLast()
    }

    // MARK: - Function Call Stack

    public func intoFunction(_ call: CalledFunction, _ srcArgs: Any?, _ tokenData: TokenData) throws {
        if call.isEvent {
            for fn in functionList where fn.isEvent {
                return  // CALLEVENT called before previous event function resolved
            }
        }

        // For now, skip argument processing - will be implemented later
        functionList.append(call)
        currentLine = call.currentLabel
        lineCount += 1
    }

    // MARK: - Get Return Address

    public func getCurrentReturnAddress() -> LogicalLine? {
        guard functionList.count != currentMin else { return nil }
        return functionList.last?.returnAddress
    }

    public func getReturnAddressSequential(_ depth: Int) -> LogicalLine? {
        guard functionList.count != currentMin else { return nil }
        let index = functionList.count - depth - 1
        guard index >= 0 && index < functionList.count else { return nil }
        return functionList[index].returnAddress
    }

    // MARK: - State Management

    public func saveCurrentState(_ single: Bool) {
        // Similar to C# for hot-reload or state preservation
    }

    public func loadPrevState() {
        // Restore previous state
    }

    public func clearFunctionList() {
        functionList.removeAll()
        beginType = .null
    }

    public func clone() -> ProcessState {
        let state = ProcessState()
        state.isClone = true
        state.currentLine = self.currentLine
        state.sysStateCode = self.sysStateCode
        state.beginType = self.beginType
        state.lineCount = self.lineCount
        state.currentMin = self.currentMin
        return state
    }
}

// MARK: - Process (Main Controller)
/// Main process controller combining state and execution logic
public final class Process {
    private var state: ProcessState
    private var originalState: ProcessState
    private var tokenData: TokenData
    private var labelDictionary: LabelDictionary
    private var executor: StatementExecutor

    // For matching functions (like C# methodStack)
    private var methodStack: Int = 0

    // For persistence
    private var prevStateList: [ProcessState] = []

    public init(tokenData: TokenData, labelDictionary: LabelDictionary) {
        self.state = ProcessState()
        self.originalState = state
        self.tokenData = tokenData
        self.labelDictionary = labelDictionary
        self.executor = StatementExecutor()
    }

    // MARK: - Accessors

    public var currentLine: LogicalLine? {
        return state.currentLine
    }

    public var scriptEnd: Bool {
        return state.scriptEnd
    }

    public var systemState: SystemStateCode {
        get { return state.systemState }
        set { state.systemState = newValue }
    }

    // MARK: - Call Management

    public func callFunction(_ label: String, _ retAddress: LogicalLine?, _ isJump: Bool = false) throws -> Bool {
        guard let called = CalledFunction.callFunction(label, retAddress, labelDictionary) else {
            return false
        }

        called.isJump = isJump
        try state.intoFunction(called, nil, tokenData)
        return true
    }

    public func callEventFunction(_ label: String, _ retAddress: LogicalLine?) throws -> Bool {
        guard let called = CalledFunction.callEventFunction(label, retAddress, labelDictionary) else {
            return false
        }

        try state.intoFunction(called, nil, tokenData)
        return true
    }

    public func jumpTo(_ label: String) throws {
        guard let called = state.currentCalled else {
            return
        }

        if let line = called.callLabel(label, called.currentLabel, labelDictionary) {
            state.jumpTo(line)
        }
    }

    // MARK: - Execution

    /// Main execution loop for script processing
    /// Executes the current function's statements using StatementExecutor
    /// - Returns: Array of output strings generated during execution
    @discardableResult
    public func runScriptProc() throws -> [String] {
        guard let currentCalled = state.currentCalled else {
            return []  // No function to execute
        }

        guard let currentLabel = currentCalled.currentLabel else {
            return []  // Function has no body
        }

        // Get the statements for this function
        let statements = currentLabel.statements

        guard !statements.isEmpty else {
            // No statements to execute, return immediately
            try state.return(0)
            return []
        }

        // Create execution context
        let context = ExecutionContext()
        context.persistEnabled = true  // Enable persistent variables

        // Execute the statements
        let outputs = executor.execute(statements, context: context)

        // Handle output
        for output in outputs {
            // In real implementation, this would go to console/output buffer
            print(output)
        }

        // Handle return value
        if let returnValue = context.returnValue {
            // Convert to Int64 if possible
            if case .integer(let value) = returnValue {
                try state.return(value)
            } else {
                try state.return(0)
            }
        } else {
            try state.return(0)
        }

        return outputs
    }

    // MARK: - Reset

    public func reset() {
        // Reset variables
        tokenData.resetAll()
        // Restore original state
        state.clearFunctionList()
    }

    // MARK: - State Operations

    public func begin() {
        state.begin()
    }

    public func setBegin(_ type: BeginType) {
        state.setBegin(type)
    }

    public func setBegin(_ keyword: String) throws {
        try state.setBegin(keyword)
    }

    // MARK: - Persistence

    public func saveCurrentState(_ single: Bool) {
        state.saveCurrentState(single)
    }

    public func loadPrevState() {
        state.loadPrevState()
    }

    public func getCurrentState() -> ProcessState {
        return state
    }
}
