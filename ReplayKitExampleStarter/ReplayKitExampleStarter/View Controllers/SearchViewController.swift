//
//  SearchViewController.swift
//  ReplayKitExampleStarter
//
//  Created by JUNYEONG.YOO on 3/11/17.
//  Copyright © 2017 chizcake. All rights reserved.
//

import UIKit
import MapKit
import CleanroomLogger

protocol SearchViewControllerDelegate {
	func didSelectLocation(_ placemark: MKPlacemark)
}

class SearchViewController: UITableViewController {
	
	// MARK: - Properties
	var searchController: UISearchController!
	var delegate: SearchViewControllerDelegate?
	var responseItems = [MKMapItem]()

	override func viewDidLoad() {
		super.viewDidLoad()

		// MARK: Settings for UISearchController
		searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.tableHeaderView = searchController.searchBar
	}

	@IBAction func dismissController(_ sender: Any) {
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
	
}

extension SearchViewController {
	// MARK: - UITableView Data Source
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return responseItems.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let item = responseItems[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
		cell.textLabel?.text = item.name
		cell.detailTextLabel?.text = CustomTools.parseToAddress(item.placemark)
		
		return cell
	}
	
	// MARK: - UITableView Delegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let delegate = self.delegate {
			let placemark = self.responseItems[indexPath.row].placemark
			delegate.didSelectLocation(placemark)
			self.dismiss(animated: false) { 
				self.navigationController?.dismiss(animated: true, completion: nil)
			}
		}
	}
}

extension SearchViewController: UISearchResultsUpdating {
	// MARK: - Search Locations from Text
	func updateSearchResults(for searchController: UISearchController) {
		searchLocation(from: searchController.searchBar.text!)
	}
	
	private func searchLocation(from text: String) {
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = text
		let search = MKLocalSearch(request: request)
		
		search.start { (searchResponse, searchError) in
			guard let response = searchResponse else { return }
			
			self.responseItems = response.mapItems
			self.tableView.reloadData()
		}
	}
}
