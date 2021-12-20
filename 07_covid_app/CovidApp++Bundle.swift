//
//  CovidApp++Bundle.swift
//  07_covid_app
//
//  Created by Jacob Ko on 2021/12/20.
//

import Foundation

extension Bundle {
	var apiKey: String {
		guard let file = self.path(forResource: "CovidKey", ofType: "plist") else { return ""}
		
		guard let resource = NSDictionary(contentsOfFile: file) else {return ""}
		guard let key = resource["API_KEY"] as? String else { fatalError("Check API Key value")}
		return key
	}
}
