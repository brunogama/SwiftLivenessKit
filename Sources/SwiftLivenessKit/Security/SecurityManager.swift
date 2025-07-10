import UIKit
import Security
import CryptoKit
import AVFoundation

// MARK: - Security Manager

/// Handles security checks and configurations for liveness detection
public actor SecurityManager {
    private let keychainService = "com.app.liveness"
    
    // MARK: - Camera Permissions
    
    public func checkCameraPermissions() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    public func requestCameraPermissions() async throws {
        guard await checkCameraPermissions() else {
            throw LivenessError.configurationFailed(reason: "Camera access denied")
        }
    }
