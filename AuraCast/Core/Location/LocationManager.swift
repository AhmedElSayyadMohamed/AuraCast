//
//  LocationService.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 11/06/2026.
//

import CoreLocation

class LocationService: NSObject, ObservableObject {
    
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
                
            case .denied, .restricted:
                cont.resume(throwing: LocationError.permissionDenied)
                self.continuation = nil
                
            @unknown default:
                cont.resume(throwing: LocationError.unknown)
                self.continuation = nil
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            continuation?.resume(throwing: LocationError.permissionDenied)
            continuation = nil
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        continuation?.resume(returning: location.coordinate)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        let clError = error as? CLError
        
        if clError?.code == .locationUnknown {
            manager.requestLocation()
            return
        }
        
        if clError?.code == .denied {
            continuation?.resume(throwing: LocationError.permissionDenied)
            continuation = nil
            return
        }
        
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

enum LocationError: LocalizedError {
    case permissionDenied
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied. Please enable it in Settings."
        case .unknown:
            return "An unknown location error occurred."
        }
    }
}
