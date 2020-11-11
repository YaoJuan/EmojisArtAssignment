//
//  EnrouteApp.swift
//  Enroute
//
//  Created by Bryce on 2020/11/11.
//

import SwiftUI

@main
struct EnrouteApp: App {
    var body: some Scene {
        WindowGroup {
            FlightsEnrouteView(flightSearch: FlightSearch(destination: "KSFO"))
        }
    }
}
