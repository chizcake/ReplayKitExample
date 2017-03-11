//
//  RecordViewController.swift
//  ReplayKitExampleStarter
//
//  Created by JUNYEONG.YOO on 3/11/17.
//  Copyright © 2017 chizcake. All rights reserved.
//

import UIKit
import MapKit
import CleanroomLogger

class RecordViewController: UIViewController {
	
	// MARK: - Properties
	var placemarks: [MKPlacemark]!
	var polylines: MKGeodesicPolyline?
	var annotations: [MKPointAnnotation]?
	
	@IBOutlet weak var mapView: MKMapView!

	// MARK: - Life Cycle of VC
	override func viewDidLoad() {
		super.viewDidLoad()

		// Check for placemarks
		if placemarks != nil {
			Log.info?.message("Number of placemarks: \(placemarks.count)")
		}
		
		// Delegate of MKMapViewDelegate
		mapView.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		showLocationOnMap(index: 0)
	}
}

extension RecordViewController: MKMapViewDelegate {
	// MARK: - MKMapView Delegate
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
		if pin == nil {
			pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
		}
		
		pin?.canShowCallout = true
		return pin
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is MKPolyline {
			let lenderer = MKPolylineRenderer(overlay: overlay)
			lenderer.strokeColor = UIColor.orange
			lenderer.lineWidth = 5.0
			return lenderer
		}
		
		return MKOverlayRenderer()
	}
	
	func showLocationOnMap(index: Int) {
		let coordinates: [CLLocationCoordinate2D] = getCoordinatesOfPlacemarks()
		
		// There's nothing annotations and overlays on the map (Initial state)
		if (mapView.annotations.count == 0) && (mapView.overlays.count == 0) {
			var annotations = [MKPointAnnotation]()
			
			// Add new annotations to the map
			for placemark in placemarks {
				let annotation = MKPointAnnotation()
				annotation.coordinate = placemark.coordinate
				annotation.title = placemark.name
				
				if let city = placemark.locality, let state = placemark.administrativeArea, let country = placemark.country {
					annotation.subtitle = "\(city) \(state), \(country)"
				}
				
				annotations.append(annotation)
			}
			
			self.annotations = annotations
			mapView.addAnnotations(annotations)
			
			// Add new polylines to the map
			let polylines = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
			mapView.add(polylines)
			self.polylines = polylines
		}
		
		// Show annotations automatically on the map
		self.mapView.selectAnnotation((self.annotations?[index])!, animated: true)
		
		// Zoom in selected location on the map
		let span = MKCoordinateSpanMake(2.0, 2.0)
		let region = MKCoordinateRegionMake(coordinates[index], span)
		mapView.setRegion(region, animated: true)
	}
	
	private func getCoordinatesOfPlacemarks() -> [CLLocationCoordinate2D] {
		var coordinates = [CLLocationCoordinate2D]()
		
		for placemark in placemarks {
			coordinates.append(placemark.coordinate)
		}
		
		return coordinates
	}
}
