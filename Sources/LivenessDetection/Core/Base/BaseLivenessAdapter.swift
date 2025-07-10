import Foundation

/// Base implementation providing common functionality
public actor BaseLivenessAdapter {
    private var _isConfigured: Bool = false
    private var currentTask: Task<Void, Never>?
    
    public var isConfigured: Bool {
        _isConfigured
    }
    
    public func setConfigured(_ value: Bool) {
        _isConfigured = value
    }
    
    public func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    public func setCurrentTask(_ task: Task<Void, Never>) {
        cancelCurrentTask()
        currentTask = task
    }
}
