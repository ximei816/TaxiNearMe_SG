//
//  CurrentLocationModel.swift
//  TaxiNearMe_SG
//
//  Created by 満尾希美 on 30/1/21.
//

import Foundation

class CurrentLocation: ObservableObject {
    @Published var latitude: String = "not available"
    @Published var longitude: String = "not available"
}
