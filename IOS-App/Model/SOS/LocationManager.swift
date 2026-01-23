//
//  LocationManager.swift
//  IOS-App
//
//  Created by SDC-USER on 08/01/26.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didReceiveLocation(lat: Double, long: Double)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let manager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }

    func getLocationOnce() {
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        delegate?.didReceiveLocation(lat: loc.coordinate.latitude,
                                     long: loc.coordinate.longitude)
        manager.stopUpdatingLocation()
    }
}
