//
//  ViewController.swift
//  07_covid_app
//
//  Created by Jacob Ko on 2021/12/18.
//

import UIKit

import Alamofire
import Charts

class ViewController: UIViewController {
	@IBOutlet weak var totalCaseLabel: UILabel!
	@IBOutlet weak var newCaseLabel: UILabel!
	@IBOutlet weak var readingDate: UILabel!
	@IBOutlet weak var pieChartView: PieChartView!
	@IBOutlet weak var labelStackView: UIStackView!
	@IBOutlet weak var indicatorView: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// app 이 실행되면 indicator 의 animation 시작
		self.indicatorView.startAnimating()
		// 순환참조를 방지하기 위해서 [weak self] 로 capture list 를 정의해줌
		self.fetchCovidOverview(completionHandler: { [weak self] result in
			guard let self = self else { return } // self 가 일시적으로 strong 이 되게 함
			// 응답이 오면 completionHandler 가 작동되기 때문에 이때 indicatorView 의 animating 을 stop 시켜 주고, hidden 시켜 주고, 나머지 information data 부분이 나타나게 해줌
			self.indicatorView.stopAnimating()
			self.indicatorView.isHidden = true
			self.labelStackView.isHidden = false
			self.readingDate.isHidden = false
			self.pieChartView.isHidden = false
			switch result {
			case let .success(result):
				// debugPrint("success: \(result)")
				self.configureNumberCase(koreaCovidOverView: result.korea)
				// pieChart 호출
				let covidOverviewList = self.makeCovidOverviewList(cityCovidOverView: result)
				self.configureChatView(covidOverviewList: covidOverviewList)
				
			case let .failure(error):
				debugPrint("error: \(error)")
			}
		})
		// updateTime Load
		self.fetchCovidTime(completionHandler: { [weak self] result in
			guard let self = self else { return } // self 가 일시적으로 strong 이 되게 함
			switch result {
			case let .success(result):
				self.configureTime(updateTime: result)
		
			case let .failure(error):
				debugPrint("error: \(error)")
			}
		})
	}
	
	
	
	// main UI 에 국내 확진자, 신규확진자 표시하기 logic
	func configureNumberCase(koreaCovidOverView: CovidOverview) {
		self.totalCaseLabel.text = "\(koreaCovidOverView.totalCase) 명"
		self.newCaseLabel.text = "\(koreaCovidOverView.newCase) 명"
	}
	
	// main UI 에 updateTime 표시하기 logic
	func configureTime(updateTime: CovidTime) {
		self.readingDate.text = "\(updateTime.updateTime)"
	}
	
	// OverviewList 생성
	func makeCovidOverviewList(cityCovidOverView: CityCovidOverView) -> [CovidOverview] {
		return [
			cityCovidOverView.seoul,
			cityCovidOverView.busan,
			cityCovidOverView.daegu,
			cityCovidOverView.incheon,
			cityCovidOverView.gwangju,
			cityCovidOverView.daejeon,
			cityCovidOverView.ulsan,
			cityCovidOverView.sejong,
			cityCovidOverView.gyeonggi,
			cityCovidOverView.chungbuk,
			cityCovidOverView.chungnam,
			cityCovidOverView.gyeongbuk,
			cityCovidOverView.gyeongnam,
			cityCovidOverView.jeonbuk,
			cityCovidOverView.jeonnam,
			cityCovidOverView.jeju,
		]
	}
	// main 에 pie 차트 표시 logic pie chart 에 pieChartDataEntry 라는 객체에 data를 추가 시켜 줘야 함. method parameter에서 전달받은 covidOverview 배열을 pieChartDataEntry 라는 객체로 mapping 시켜 줘야 함
	func configureChatView(covidOverviewList: [CovidOverview]) {
		self.pieChartView.delegate = self // PieChart delegate 생성
		let entries = covidOverviewList.compactMap {[weak self] overview -> PieChartDataEntry? in
			guard let self = self else { return nil } // 일시적으로 self 각 strong reference 가 되게 함
			return PieChartDataEntry(
				value: self.removeFormatString(string: overview.newCase), // 차트항목에 들어가는 값을 double type 으로 넣어줌
				label: overview.countryName, // 라벨이름
				data: overview // 시도별 코로나 현황 상세 데이터를 가질 수 있게 만들어 줌
			)
		}
		// PieChartDataSet으로 항목을 묶어줌
		let dataSet = PieChartDataSet(entries: entries, label: "지역별 코로나 발생 현황")
		// PieChart Design
		dataSet.sliceSpace = 2 // 항목간의 간격 1pt
		dataSet.entryLabelColor = .systemGray // 항목 이름 색 black
		dataSet.valueTextColor = .black //  항목 안에 있는 value 값을 black 으로
		dataSet.xValuePosition = .outsideSlice // 항목 이름이 pie Chart 에 표시 하지 않고 밖에 표시하게 하기
		dataSet.valueLinePart1OffsetPercentage = 0.8
		dataSet.valueLinePart1Length = 0.2
		dataSet.valueLinePart2Length = 0.3 // 라인이 잘 보일 수 있게 설정
		
		// colors 에 다양한 색을 추가하면, pieChart 가 다양한 색상으로 표시 되게 됨
		dataSet.colors = ChartColorTemplates.vordiplom() +
		ChartColorTemplates.joyful() +
		ChartColorTemplates.liberty() +
		ChartColorTemplates.pastel() +
		ChartColorTemplates.material()
		
		self.pieChartView.data = PieChartData(dataSet: dataSet) // pieChart 에 데이터 삽임
		// pieChart 회전 시키기 현재 상태에서 80도정도 회전 시킨 상태로 만듬
		self.pieChartView.spin(duration: 0.3, fromAngle: self.pieChartView.rotationAngle, toAngle: self.pieChartView.rotationAngle + 80)
		
	}
	
	// json 형식에 신규 확진자 수가, 숫자3자리마다 , 을 찍어주는 String 으로 되어 있는데 -> 이것을 double type 으로 바꾸는 method
	func removeFormatString(string: String) -> Double {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		return formatter.number(from: string)?.doubleValue ?? 0
	}
	
	
	// fetch data SearchCovideOverview
	func fetchCovidOverview(
		// API 를 통해서 sever에서 json dat 를 받거나, 요청에 실패 하였을때 completionHandler 를 호출해서 해당 closure 를 정의하는 곳에 응답받은 data를 전달 해야 합니다
		// completionHandler 를 @escaping closure 가 되게 설정
		completionHandler: @escaping (Result<CityCovidOverView, Error>) -> Void
	) {
		let apiKey = Bundle.main.apiKey
		let url = "https://api.corona-19.kr/korea/country/new/"
		let param = [
			"serviceKey": apiKey
		]
		
		// Alamofire 를 통해서 API 호출
		AF.request(url, method: .get, parameters: param)
			.responseData(completionHandler: { response in
				switch response.result {
				case let .success(data):
					do {
						let decoder = JSONDecoder()
						let result = try decoder.decode(CityCovidOverView.self, from: data)
						completionHandler(.success(result))
					} catch { // error code 처리
						completionHandler(.failure(error))
					}
				case let .failure(error):
					completionHandler(.failure(error))
				}
			})
	}
	
	
	// fetch CovidTime SearchCovideOverview
	func fetchCovidTime(
		// API 를 통해서 sever에서 json dat 를 받거나, 요청에 실패 하였을때 completionHandler 를 호출해서 해당 closure 를 정의하는 곳에 응답받은 data를 전달 해야 합니다
		// completionHandler 를 @escaping closure 가 되게 설정
		completionHandler: @escaping (Result<CovidTime, Error>) -> Void
	) {
		let apiKey = Bundle.main.apiKey
		let url = "https://api.corona-19.kr/korea/"
		let param = [
			"serviceKey": apiKey
		]
		
		// Alamofire 를 통해서 API 호출
		AF.request(url, method: .get, parameters: param)
			.responseData(completionHandler: { response in
				switch response.result {
				case let .success(data):
					do {
						let decoder = JSONDecoder()
						let result = try decoder.decode(CovidTime.self, from: data)
						completionHandler(.success(result))
					} catch { // error code 처리
						completionHandler(.failure(error))
					}
				case let .failure(error):
					completionHandler(.failure(error))
				}
			})
	}
}

// PieChart 를 누를때 covidDetailController 가 push 되게 구현하기
extension ViewController: ChartViewDelegate {
	// 차트에서 항목을 선택하였을때 호출이 되는 metho , entry parameter의 method 를 통해서 선택된 항목에 저장된 data 를 가져 올 수 있음
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		guard let covidDetailViewController = self.storyboard?.instantiateViewController(identifier: "CovidDetailViewController") as? CovidDetailViewController else { return }
		guard let covidOverview = entry.data as? CovidOverview else { return }
		covidDetailViewController.covidOverview = covidOverview // covidDetailViewController 에 저장된 data 전송
		self.navigationController?.pushViewController(covidDetailViewController, animated: true) // 항목을 누르면 push 되게 이동 시킴
	}
}
