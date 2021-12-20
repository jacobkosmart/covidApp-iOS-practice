//
//  CovidDetailViewController.swift
//  07_covid_app
//
//  Created by Jacob Ko on 2021/12/19.
//

import UIKit

class CovidDetailViewController: UITableViewController {
	@IBOutlet weak var newCaseCell: UITableViewCell!
	@IBOutlet weak var totalCaseCell: UITableViewCell!
	@IBOutlet weak var recorveredCell: UITableViewCell!
	@IBOutlet weak var deathCell: UITableViewCell!
	@IBOutlet weak var percentageCell: UITableViewCell!
	@IBOutlet weak var overseaseInflowCell: UITableViewCell!
	@IBOutlet weak var regionalOutbreakCell: UITableViewCell!
	
	
	var covidOverview: CovidOverview?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureView()
	}
	
	// listView 보는 method
	func configureView() {
		guard let covidOverview = self.covidOverview else { return }
		self.title = covidOverview.countryName
		self.newCaseCell.detailTextLabel?.text = "\(covidOverview.newCase) 명"
		self.totalCaseCell.detailTextLabel?.text = "\(covidOverview.totalCase) 명"
		self.recorveredCell.detailTextLabel?.text = "\(covidOverview.recovered) 명"
		self.deathCell.detailTextLabel?.text = "\(covidOverview.death) 명"
		self.percentageCell.detailTextLabel?.text = "\(covidOverview.percentage) %"
		self.overseaseInflowCell.detailTextLabel?.text = "\(covidOverview.newFcase) 명"
		self.regionalOutbreakCell.detailTextLabel?.text = "\(covidOverview.newCase) 명"
	}
	
}
