//
//  ContentView.swift
//  TaxiNearMe_SG
//
//  Created by 満尾希美 on 30/1/21.
//  ref: https://stackoverflow.com/questions/40446479/how-do-i-get-a-specific-value-from-returned-json-in-swift-3-0

import Foundation
import SwiftUI
import CoreLocation
import MapKit

struct TaxiLocation: Identifiable {
    var id = UUID()
    var loc: CLLocationCoordinate2D
}

struct ContentView: View {
    
    @ObservedObject var currentLoc = CurrentLocation()

    var manager = CLLocationManager()
    var managerDelegate = LocationDelegate()
    
    @State var responses: [TaxiLocation] = []
    @State var taxi_in_500m = 0
    @State var taxi_in_1000m = 0
    @State var taxi_in_2000m = 0
    
    var map_span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    
    @State private var region =
        MKCoordinateRegion(center: CLLocationCoordinate2D(
                            latitude: 1.2870222,
                            longitude: 103.8546889),
                           span: MKCoordinateSpan(
                            latitudeDelta: 10,
                            longitudeDelta: 10))
    
    var body: some View {
        VStack {
            //if location is not set
            Button(action: {
                //set current location
                currentLoc.latitude = managerDelegate.currentLatitude
                currentLoc.longitude = managerDelegate.currentLongitude
                region = MKCoordinateRegion(center: CLLocationCoordinate2D(
                                                latitude: Double(currentLoc.latitude)!,
                                                longitude: Double(currentLoc.longitude)!),
                                       span: map_span)
                //count taxies
                LoadData()
            }, label: {
                Text("Set Current Location")
            })
            
            //if location is set
            if currentLoc.latitude != "not available" {
                //Map
                Map(coordinateRegion: $region, annotationItems: responses) { item in
                    MapPin(coordinate: item.loc)
                }
                HStack{
                    VStack{
                        Text("500m - \(taxi_in_500m)")
                        Text("1km - \(taxi_in_1000m)")
                        Text("2km - \(taxi_in_2000m)")
                        Text("All - \(responses.count)")
                    }
                    Button(action: {
                        LoadData()
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                    }).padding()
                }
                
            }
        }
        .onAppear() {
            manager.delegate = managerDelegate
            managerDelegate.locationManagerDidChangeAuthorization(manager)
            LoadData()
        }
    }
    
    
    
    func LoadData() {
        
        var loadData:[TaxiLocation] = []
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.remove(.withTimeZone)
        formatter.timeZone = TimeZone(identifier: "Asia/Singapore")!
        
        let dtStr = formatter.string(from: Date()).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        print("https://api.data.gov.sg/v1/transport/taxi-availability?date_time=\(dtStr!)")
        
        guard let url = URL(string: "https://api.data.gov.sg/v1/transport/taxi-availability?date_time=\(dtStr!)") else {
            print("url error")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let json =  (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String:Any]
              , let features = json["features"] as? [Any]
              , let firstFeature = features[0] as? [String:Any]
              , let geometry = firstFeature["geometry"] as? [String:Any]
              , let coordinates = geometry["coordinates"] as? [NSArray]
            {
                for item in coordinates {
                    loadData.append(
                        TaxiLocation(loc: CLLocationCoordinate2D(latitude: item[1] as! Double, longitude: item[0] as! Double))
                    )
                }
                responses = loadData
            }
            
            if currentLoc.latitude != "not available" {
                SetTaxiCount()
            }
            
        }.resume()
    }
    
    func SetTaxiCount(){
        taxi_in_500m = TaxiCount(here: currentLoc, response: responses, radius: 500)
        taxi_in_1000m = TaxiCount(here: currentLoc, response: responses, radius: 1000)
        taxi_in_2000m = TaxiCount(here: currentLoc, response: responses, radius: 2000)
    }
    
    func TaxiCount(here: CurrentLocation, response: [TaxiLocation], radius: Double) -> Int {
        
        var taxiCnt = 0
        
        let centerLocation = CLLocation(latitude:Double(here.latitude)!, longitude:Double(here.longitude)!)
        
        for taxi in response {
            let taxiLocation = CLLocation(latitude: taxi.loc.latitude, longitude: taxi.loc.longitude)
            let distance = centerLocation.distance(from: taxiLocation)
            
            if distance <= radius {
                taxiCnt += 1
            }
        }
        
        return taxiCnt
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
