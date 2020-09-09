//
//  FilterMapData.swift
//  Hustle
//
//  Created by Franco on 2020-04-04.
//  Copyright © 2020 Casual Mobile. All rights reserved.
//

import Foundation
import MapKit
import UIKit


enum zoomLevels: Double {
    case defaultZoomLevel = 1000000
    case maxZoomLevel = 5000000
}

enum StoreMapDataKey: String {
    case mapData = "mapData.json"
}

struct FilterMapData: Codable {
    
    let addressString: String
    let centerPoint: CLLocationCoordinate2D
    let neRegionPoint: CLLocationCoordinate2D
    let swRegionPoint: CLLocationCoordinate2D

    enum CodingKeys: CodingKey {
        case addressString
        case centerLat
        case centerLong
        case NELat
        case NELong
        case SWLat
        case SWLong
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(addressString, forKey: .addressString)
        try container.encode(centerPoint.latitude, forKey: .centerLat)
        try container.encode(centerPoint.longitude, forKey: .centerLong)
        try container.encode(neRegionPoint.latitude, forKey: .NELat)
        try container.encode(neRegionPoint.longitude, forKey: .NELong)
        try container.encode(swRegionPoint.latitude, forKey: .SWLat)
        try container.encode(swRegionPoint.longitude, forKey: .SWLong)
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.addressString = try container.decode(String.self, forKey: .addressString)
        let centerLat = try container.decode(Double.self, forKey: .centerLat)
        let centerLong = try container.decode(Double.self, forKey: .centerLong)
        let NELat = try container.decode(Double.self, forKey: .NELat)
        let NELong = try container.decode(Double.self, forKey: .NELong)
        let SWLat = try container.decode(Double.self, forKey: .SWLat)
        let SWLong = try container.decode(Double.self, forKey: .SWLong)
        
        let centerPoint = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong)
        let NEPoint = CLLocationCoordinate2D(latitude: NELat, longitude: NELong)
        let SWPoint = CLLocationCoordinate2D(latitude: SWLat, longitude: SWLong)
        
        self.centerPoint = centerPoint
        self.neRegionPoint = NEPoint
        self.swRegionPoint = SWPoint
    }
    
    init(addressString: String, centerPoint: CLLocationCoordinate2D, neRegionPoint: CLLocationCoordinate2D, swRegionPoint: CLLocationCoordinate2D) {
        self.addressString = addressString
        self.centerPoint = centerPoint
        self.neRegionPoint = neRegionPoint
        self.swRegionPoint = swRegionPoint
    }
    
    init?(zoom: zoomLevels) {
        
        let locationManager = CLLocationManager()
        addressString = "Your Location"
        guard let location = locationManager.location else {
            return nil
        }
        centerPoint = location.coordinate
        (neRegionPoint, swRegionPoint) = FilterMapData.getDefaultMapSetUp(centerPoint: location.coordinate, zoomLevel: zoom)
    }
    
    static func getDefaultMapSetUp(centerPoint: CLLocationCoordinate2D, zoomLevel: zoomLevels)-> (CLLocationCoordinate2D, CLLocationCoordinate2D){
        
        let mapSize = MKMapSize(width: zoomLevel.rawValue, height: zoomLevel.rawValue)
        let mapPoint = MKMapPoint(centerPoint)

        let rect = MKMapRect(origin: mapPoint, size: mapSize)
        
        let maxX = rect.maxX
        let minX = rect.minX
        let maxY = rect.maxY
        let minY = rect.minY
        
        // Set orgin to be centered on location
        let centerX = rect.origin.x - (maxX - minX)/2
        let centerY = rect.origin.y - (maxY - minY)/2
        
        let newCenter = MKMapPoint(x: centerX, y: centerY)
        
        let centeredRect = MKMapRect(origin: newCenter, size: mapSize)
        
        let maxXCenter = centeredRect.maxX
        let minXCenter = centeredRect.minX
        let maxYCenter = centeredRect.maxY
        let minYCenter = centeredRect.minY
        
        let nePointCenter = MKMapPoint(x: maxXCenter, y: minYCenter)
        let swPointCenter = MKMapPoint(x: minXCenter, y: maxYCenter)
        
        return (nePointCenter.coordinate, swPointCenter.coordinate)
    }
}
