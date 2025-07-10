import Foundation

/// Events emitted during liveness detection
public enum LivenessEvent: Sendable {
    case started
    case progress(percentage: Double)
    case instructionChanged(String)
    case completed(LivenessResult)
    case failed(LivenessError)
}
