//
//  CustomTools.swift
//  ReplayKitExampleStarter
//
//  Created by JUNYEONG.YOO on 3/11/17.
//  Copyright © 2017 chizcake. All rights reserved.
//

import Foundation
import MapKit

public class CustomTools {
	public class func parseToAddress(_ placemark: MKPlacemark) -> String {
		// Put a space between street number and street name
		let spaceStreet = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
		
		// Put a comma between street name and city
		let commaStreetAndCity = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil)
			&& (placemark.locality != nil || placemark.administrativeArea != nil) ? ", " : ""
		
		// Put a space between city and administrative area
		let spaceCity = (placemark.locality != nil && placemark.administrativeArea != nil) ? " " : ""
		
		// Put a comma between city and country
		let commaCityAndCountry = (placemark.locality != nil || placemark.administrativeArea != nil)
			&& (placemark.country != nil) ? ", " : ""
		
		let addressLine = String(format: "%@%@%@%@%@%@%@%@%@",
		                         // Street Number
			placemark.subThoroughfare ?? "",
			spaceStreet,
			// Street name
			placemark.thoroughfare ?? "",
			commaStreetAndCity,
			// City
			placemark.locality ?? "",
			spaceCity,
			// State
			placemark.administrativeArea ?? "",
			commaCityAndCountry,
			// Country
			placemark.country ?? ""
		)
		
		return addressLine
	}
}
