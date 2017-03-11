//
//  MasterViewController.swift
//  ReplayKitExampleStarter
//
//  Created by JUNYEONG.YOO on 3/11/17.
//  Copyright © 2017 chizcake. All rights reserved.
//

import UIKit
import MapKit
import CleanroomLogger

class MasterViewController: UIViewController {

	// MARK: - Properties
	var placemarks = [MKPlacemark]()
	@IBOutlet weak var tableView: UITableView!
	
	// MARK: - Life Cycle of VC
	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.delegate = self
		self.tableView.dataSource = self
	}

	// MARK: - Segues
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowSearchViewController" {
			let controller = (segue.destination as! UINavigationController).topViewController as! SearchViewController
			controller.delegate = self
		} else if segue.identifier == "ShowRecordViewController" {
			let controller = segue.destination as! RecordViewController
			controller.placemarks = self.placemarks
		}
	}
}

extension MasterViewController: UITableViewDelegate, UITableViewDataSource {
	// MARK: - UITableView Data Source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.placemarks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MasterCell", for: indexPath)
		let placemark = self.placemarks[indexPath.row]
		cell.textLabel?.text = CustomTools.parseToAddress(placemark)
		
		return cell
	}
	
	// MARK: - UITableView Delegate
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			self.placemarks.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
}

extension MasterViewController: SearchViewControllerDelegate {
	func didSelectLocation(_ placemark: MKPlacemark) {
		self.placemarks.append(placemark)
		self.tableView.reloadData()
	}
}
