//
//  LocationDelegate.swift
//  TaxiNearMe
//
//  Created by 満尾希美 on 28/1/21.
//  from: https://laptrinhx.com/mapkitwo-shitteswiftui2-0denodelegateno-shuki-fangnosanpuruwo-zuottemita-1346488327/

import CoreLocation

class LocationDelegate : NSObject, ObservableObject, CLLocationManagerDelegate {

    // delegateから取り出すための@Pubishedな変数
    @Published var currentLatitude: String = "not available"
    @Published var currentLongitude: String = "not available"

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        if manager.authorizationStatus == .authorizedWhenInUse {
            print("authorized")

            manager.startUpdatingLocation()

            // add "Privacy - Location Default Accuracy Reduced" in info.plist
            // and edit in souce code that value is <true/> or <false/>
            if manager.accuracyAuthorization != .fullAccuracy {
                print("reduce accuracy")

                // add "Privacy - Location Temporary Usage Description Dictionary" in info.plist
                // and set "Location" in Key
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Location") {
                    (err) in
                    if err != nil {
                        print(err!)
                        return
                    }
                }
            }
        } else {
            print("not authorized")
            // add "Privacy - Location When In Use Usage Description" in info.plist
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {

            currentLatitude = String(format: "%+.06f", location.coordinate.latitude)
            currentLongitude = String(format: "%+.06f", location.coordinate.longitude)

        }
    }
}
