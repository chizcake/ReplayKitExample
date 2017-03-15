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
import ReplayKit

class RecordViewController: UIViewController {
	
	// MARK: - Properties
	var placemarks: [MKPlacemark]!
	var polylines: MKGeodesicPolyline?
	var annotations: [MKPointAnnotation]?
	
	// 0. 현재 녹화 여부를 확인합니다.
	var isRecording: Bool = false
	
	var timer: Timer?
	var currentLocation: Int = 0
	
	// 9. 녹화가 시작되면 Status bar를 감춥니다.
	override var prefersStatusBarHidden: Bool {
		return (self.navigationController?.isNavigationBarHidden)!
	}
	
	@IBOutlet weak var barButton: UIBarButtonItem!
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
	
	// MARK: - Start Recording Button
	@IBAction func barButtonAction(_ sender: UIBarButtonItem) {
		if sender.title == "Start Recording" {
			Log.info?.message("Start Recording!")
			sender.title = "Stop Recording"
			startRecording()
		} else if sender.title == "Stop Recording" {
			Log.info?.message("Stop Recording!")
			sender.title = "Start Recording"
			stopRecording()
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if isRecording {
			// 녹화중에 화면을 터치하면 숨겨둔 navigation bar를 다시 보여줍니다.
			if (navigationController?.isNavigationBarHidden)! {
				navigationController?.isNavigationBarHidden = false
			} else {
				navigationController?.isNavigationBarHidden = true
			}
		}
	}
}

extension RecordViewController: RPPreviewViewControllerDelegate {
	// MARK: - Start Recording
	func startRecording() {
		// 1. RPScreenRecorder 공유 객체를 호출합니다.
		let recorder = RPScreenRecorder.shared()
		
		// 10. 녹화가 시작되면 Navigation Bar를 숨겨줍니다.
		self.navigationController?.isNavigationBarHidden = true
		
		recorder.startRecording { (recordingError) in
			// 1-1. 녹화 중 에러가 발생하면 에러 메시지를 확인하고 메서드를 종료합니다.
			if let error = recordingError {
				Log.error?.message(error.localizedDescription)
				self.barButton.title = "Start Recording"
				self.navigationController?.isNavigationBarHidden = false
			} else {
				// 2. 녹화가 정상적으로 시작하면 지도를 자동으로 움직이게 합니다.
				self.isRecording = true
				self.startAnimatingMap()
			}
		}
	}
	
	// MARK: - Stop Recording
	func stopRecording() {
		let recorder = RPScreenRecorder.shared()
		
		if isRecording {
			// 7-1. 사용자가 녹화 중간에 녹화를 종료하는 경우
			Log.warning?.message("Stop recording unexpectedly")
			recorder.stopRecording(handler: { (previewController, recordingError) in
				if let error = recordingError {
					Log.error?.message(error.localizedDescription)
				} else {
					// 현재 녹화되고 있던 내용을 모두 버립니다.
					recorder.discardRecording {
						self.timer?.invalidate()
						self.timer = nil
						self.currentLocation = 0
					}
				}
			})
		} else {
			// 7-2. 지도가 모두 움직이고, 정상적으로 녹화를 종료하는 경우
			Log.info?.message("Stop recording normally")
			recorder.stopRecording(handler: { (previewController, recordingError) in
				if let error = recordingError {
					Log.error?.message(error.localizedDescription)
				} else {
					// 7-3. 녹화 결과를 확인할 PreviewViewController를 Modal로 보여줍니다.
					if let controller = previewController {
						controller.previewControllerDelegate = self
						self.present(controller, animated: true, completion: nil)
					} else {
						Log.warning?.message("There's no PreviewController")
					}
				}
			})
		}
		
		// 11. 녹화가 종료되면 Navigation Bar를 원상태로 복구합니다.
		self.navigationController?.isNavigationBarHidden = false
		barButton.title = "Start Recording"
		showLocationOnMap(index: 0)
	}
	
	// MARK: - Automatically Animates Map
	func startAnimatingMap() {
		if currentLocation == 0 {
			showLocationOnMap(index: currentLocation)
			currentLocation += 1
		}
		
		// 3. 3초에 한 번씩 지도가 움직일 수 있도록 타이머를 설정해줍니다.
		timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(animatesMap), userInfo: nil, repeats: true)
	}
	
	func animatesMap() {
		Log.info?.message("animatesMap()")
		if currentLocation < placemarks.count {
			// 4. timer에 맞춰 지도가 움직이게 합니다.
			showLocationOnMap(index: currentLocation)
			currentLocation += 1
		} else {
			// 4-1. 지도가 모두 움직이면 timer를 종료하고 녹화를 종료합니다.
			currentLocation = 0
			stopAnimatingMap()
		}
	}
	
	func stopAnimatingMap() {
		guard let timer = self.timer else { return }
		// 5. 타이머를 종료합니다.
		timer.invalidate()
		self.timer = nil
		self.isRecording = false
		// 6. 녹화를 종료합니다.
		stopRecording()
	}
	
	// MARK: - RPPreviewViewController Delegate
	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		// 8. PreviewViewController에서 작업이 끝나면 화면을 MasterViewController로 이동시킵니다.
		previewController.dismiss(animated: true) { 
			let _ = self.navigationController?.popViewController(animated: true)
		}
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
