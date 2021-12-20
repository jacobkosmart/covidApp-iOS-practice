# 💉 CovidApp-iOS-practice

<!-- todo gif -->

## 📌 기능 상세

- 시도별 신규 확진자 수가 파이 차트로 표시 되어야 합니다

- 도시 항목을 선택하면 상세 현황을 볼 수 있는 화면으로 이동되어야 합니다.

## 🔑 Check Point !

<!-- todo  스크린샷 -->

### 🔷 App Model

```swift
// in CityCovidOverView.swift

import Foundation

struct CityCovidOverView: Codable {
	let korea: CovidOverview
	let seoul: CovidOverview
	let busan: CovidOverview
	let daegu: CovidOverview
	let incheon: CovidOverview
	let gwangju: CovidOverview
	let daejeon: CovidOverview
	let ulsan: CovidOverview
	let sejong: CovidOverview
	let gyeonggi: CovidOverview
	let gangwon: CovidOverview
	let chungbuk: CovidOverview
	let chungnam: CovidOverview
	let jeonbuk: CovidOverview
	let jeonnam: CovidOverview
	let gyeongbuk: CovidOverview
	let gyeongnam: CovidOverview
	let jeju: CovidOverview
}

struct CovidOverview: Codable {
	let countryName: String
	let newCase: String
	let totalCase: String
	let recovered: String
	let death: String
	let percentage: String
	let newCcase: String
	let newFcase: String
}

// in CovidTime.swift

import Foundation
struct CovidTime: Codable {
	let updateTime: String
}

```

### 🔷 굿바이 코로나 19 API

### 🔷 Alamofire

#### completionHandler 의 escaping closure 선언 이유

- func 에서 escape 선언은 함수의 scope 를 벗어 나서도 변수가 참조 될 수 있게 하는 클로져 임. 즉, 함수의 인자로 closure 가 전달되지만, 반환된 후에도 실행되는 것을 의미합니다.

- escaping closure 를 사용하는 대표적인 경우는 비동기 작업을 하는 경우 completionHandler 로서 escaping closure 를 많이 사용합니다. 보통 네트워킹 통신은 비동기 작업으로 처리 되는데, `.responseData` 에 정의된 `completionHandler closure` 는 fetch data 가 반환 된 후에, 호출이 됩니다. 왜냐하면, 서버에서 데이터를 언제 응답 해줄지 모르고, 응답시간이 로딩 되기 때문에 server 에서 비동기로 응답 받기 전에 즉, .responseData 에 전달한 parameter 가 completionHandler가 호출되기 전에 함수가 종료되서 서버의 응답을 받아도 동작하지 않게 됩니다

- 그래서, 비동기 작업을 completionHandler 로 callback 을 시켜줘야 한다면, escaping closure 를 사용하여 함수가 return 된 후에도, 실행 시켜줘야 합니다

```swift
// in viewDidLoad.swift

	// fetch data SearchCovideOverview
	func fetchCovidOverview(
		// API 를 통해서 sever에서 json dat 를 받거나, 요청에 실패 하였을때 completionHandler 를 호출해서 해당 closure 를 정의하는 곳에 응답받은 data를 전달 해야 합니다
		// completionHandler 를 @escaping closure 가 되게 설정
		completionHandler: @escaping (Result<CityCovidOverView, Error>) -> Void
	) {
		let url = "https://api.corona-19.kr/korea/country/new/"
		let param = [
			"serviceKey": "16KIXAdhg7tk93ivjzsHFCQ8oOLyNSUuE"
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

```

### 🔷 Cocoapods

> Describing check point in details in Jacob's DevLog - https://jacobko.info/ios/ios-06/

### 🔷 Loading indicator

- ViewController 에 loading indicator 를 표시하여, Covid API 를 호출 하였을 때, 서버에서 응답이 오기 전이라면 화면에 indicator 가 표시되게 구현하기

- 서버에서 응답이 온다면, indicator 를 숨기고 label 과 pieChart 가 표시되게 구현 하기

#### 구현 방법

- storyboard 에서 Activity Indicator 추가 한다음에 기존에 StackView의 label, pieChartView 에는 hidden 을 체크 해줘서 잠시 숨김니다

```swift
// in ViewController.swift

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
  ......
    }
  }
```

### 🔷 API Key 숨기기

- GitHub 나 외부로 public 하게 project 공유시, apiKey 나, passWord, authentication 관련 key 값들을 외부에 노출 시키지 않기 위해서 code 에 key 값을 바로 적는것이 아니라, plist (property list) 를 생성해줘서 따로 관리 해야 합니다

<!-- ## ❌ Error Check Point

### 🔶 -->

---

🔶 🔷 📌 🔑 👉

## 🗃 Reference

Jacob's DevLog - [https://jacobko.info/uikit/ios-08/](https://jacobko.info/uikit/ios-08/)

나른한 코딩 - [https://nareunhagae.tistory.com/44](https://nareunhagae.tistory.com/44)
