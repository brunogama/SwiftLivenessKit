import Foundation

// MARK: - Events and Base Implementation

/// Events emitted during liveness detection
public enum LivenessEvent: Sendable {
    case started
    case progress(percentage: Double)
    case instructionChanged(String)
    case completed(LivenessResult)
    case failed(LivenessError)
}

/// Base implementation providing common functionality
public actor BaseLivenessAdapter {
    private var _isConfigured: Bool = false
    private var currentTask: Task<Void, Never>?
    
    public var isConfigured: Bool {
        _isConfigured
    }
    
    func setConfigured(_ value: Bool) {
        _isConfigured = value
    }
    
    func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    func setCurrentTask(_ task: Task<Void, Never>) {
        cancelCurrentTask()
        currentTask = task
    }
}