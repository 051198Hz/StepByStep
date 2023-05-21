//
//  ViewController.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/02.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKShare
import Alamofire

class RoutineAndTodo: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UISheetPresentationControllerDelegate{
    var currentTavleView : Int!
    
    @IBOutlet var DayBtns: [UIButton]!
    @IBOutlet var chart: UIView!
    
    @IBOutlet var delBoxShowBtn: UIButton!
    
    @IBOutlet var addItemBtn: UIButton!
    
    var indexOfOneAndOnlySelectedBtn: Int?
    var check = 0
    var delBtnChecked : Bool = false
    
    var DB = DAO.shareInstance()
    var routine : Routine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DB.delete()
        // Do any additional setup after loading the view.
        currentTavleView = 0
        
        for index in DayBtns.indices {
            DayBtns[index].layer.borderWidth = 1.0
            DayBtns[index].layer.borderColor = UIColor.lightGray.cgColor
            DayBtns[index].circleButton = true
            //            DayBtns[index].setBackgroundImage(UIImage(named: "unCheck"), for: .selected)
            //DayBtns[index].setBackgroundImage(UIImage(named: "Check"), for: .normal)
        }
        setChart()
        tableSet()
        RoutuneAndTodoTable.delegate = self
        RoutuneAndTodoTable.dataSource = self
        
        kakaoLogin()
        
    }
    
    func tableSet(){
        RoutuneAndTodoTable.backgroundColor = UIColor(red: 192, green: 192, blue: 192, alpha: 1)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        RoutuneAndTodoTable.addGestureRecognizer(longPress)
    }
    
    @IBOutlet var RoutuneAndTodoTable: UITableView!
    @IBOutlet var RoutineTodoSeg: UISegmentedControl!
    
    @IBAction func SwitchRoutuneTodo(_ sender: UISegmentedControl) {
        currentTavleView = sender.selectedSegmentIndex
        getRoutine_reload()
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: RoutuneAndTodoTable)
            if let indexPath = RoutuneAndTodoTable.indexPathForRow(at: touchPoint) {
                let cell = (RoutuneAndTodoTable.cellForRow(at: indexPath)) as! testCell
                if(cell.discLabel.text != "⁉️"){
                    //액션시트로 메뉴 띄욱,, 근데 맘에안듬
                    let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
                    
                    let cancelActionButton = UIAlertAction(title: "완료", style: .default) { _ in
                        print("완료")
                    }
                    actionSheetControllerIOS8.addAction(cancelActionButton)
                    
                    let saveActionButton = UIAlertAction(title: "실패", style: .default)
                    { _ in
                        print("실패")
                    }
                    actionSheetControllerIOS8.addAction(saveActionButton)
                    
                    let deleteActionButton = UIAlertAction(title: "수정", style: .default)
                    { _ in
                        print("수정")
                    }
                    actionSheetControllerIOS8.addAction(deleteActionButton)
                    if UIDevice.current.userInterfaceIdiom == .pad { //디바이스 타입이 iPad일때
                        if let popoverController = actionSheetControllerIOS8.popoverPresentationController {
                            // ActionSheet가 표현되는 위치를 저장해줍니다.
                            popoverController.sourceView = self.view
                            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height * 4 / 5 , width: 0, height: 0)
                            popoverController.permittedArrowDirections = []
                            self.present(actionSheetControllerIOS8, animated: true, completion: nil)
                        }
                    } else {
                        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
                    }
                    
                    
                    //                /바텀에서 올라오는거, 그러나 메뉴를 구현해야함...
                    //                let vc = UIViewController()
                    //                vc.view.backgroundColor = .lightGray
                    //
                    //
                    //                        vc.modalPresentationStyle = .pageSheet
                    //
                    //                        if let sheet = vc.sheetPresentationController {
                    //
                    //                            //지원할 크기 지정
                    //                            sheet.detents = [ .medium(), .medium()]
                    //                            //크기 변하는거 감지
                    //                            sheet.delegate = self
                    //
                    //                            //시트 상단에 그래버 표시 (기본 값은 false)
                    //                            sheet.prefersGrabberVisible = true
                    //
                    //                            //처음 크기 지정 (기본 값은 가장 작은 크기)
                    //                            //sheet.selectedDetentIdentifier = .large
                    //
                    //                            //뒤 배경 흐리게 제거 (기본 값은 모든 크기에서 배경 흐리게 됨)
                    //                            //sheet.largestUndimmedDetentIdentifier = .medium
                    //                        }
                    //                present(vc, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    /// Description
    /// - Parameter sender: sender description
    @IBAction func delBoxShowBtnPressed(_ sender: Any) { //셀 삭제박스 활성화
        let firstIdx = IndexPath(row: 0, section: 0)
        
        if(RoutuneAndTodoTable.visibleCells.isEmpty || ((RoutuneAndTodoTable.cellForRow(at: firstIdx) as! testCell).discLabel.text == "⁉️") ){//삭제불가
            let alert = UIAlertController(title: "알림", message: "삭제할수 있는 항목이 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [self] action in
            })
            self.present(alert, animated: true, completion: nil)
            return
        }
        if(delBtnChecked == false){//처음 삭제버튼 클릭
            for cell  in RoutuneAndTodoTable.visibleCells {
                (cell as! testCell).delCehckBox.isHidden = false
            }
            delBtnChecked = true
        }else{//삭제더블체크
            let alert = UIAlertController(title: "알림", message: "정말 삭제하시겠습니까??", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .default) { [self] action in
                //취소처리...

                
                for cell in RoutuneAndTodoTable.visibleCells {
                    (cell as! testCell).delCehckBox.isHidden = true
                }
            })
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [self] action in
                //확인처리...
                /*
                 for cell  in RoutuneAndTodoTable.visibleCells {
                 if( (cell as! testCell).체크면 ){
                 셀 삭제
                 }
                 }
                 */
                
                var idxs : [IndexPath] = .init()
                for cell in RoutuneAndTodoTable.visibleCells{
                    let delCell = (cell as! testCell)
                    if(delCell.delCehckBox.isChecked){
                        let delIdx = RoutuneAndTodoTable.indexPath(for: cell)
                        idxs.append(delIdx!)
                        DB.delete((DayBtns[indexOfOneAndOnlySelectedBtn!].titleLabel?.text)!, delCell.label.text!, delCell.discLabel.text!)
                    }
                }
                print("삭제 대상 : ", idxs)
                for item in idxs{
                    let item = item as IndexPath
                    print("행 : ", item.row)
                    print("섹션 : " , item.section)
                }

                //RoutuneAndTodoTable.deleteRows(at: idxs, with: .fade)
                
                for cell  in RoutuneAndTodoTable.visibleCells {
                    (cell as! testCell).delCehckBox.isHidden = true
                }
                getRoutine_reload()
                
            })
            self.present(alert, animated: true, completion: nil)
            delBtnChecked = false
        }
        
        /*
         
         for cell  in RoutuneAndTodoTable.visibleCells {
         (cell as! testCell).delCehckBox.isHidden = true
         }
         */
        
        
    }
    
    @IBAction func addItemBtnPressed(_ sender: Any) {
        
        
        if(self.indexOfOneAndOnlySelectedBtn==nil){
            let alert = UIAlertController(title: "알림", message: "요일을 선택하세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [self] action in
            })
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemAddPopupView") as! AddItemPopupView
        vc.indexOfOneAndOnlySelectedBtn = self.indexOfOneAndOnlySelectedBtn
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
        
    }
    
    
    func setChart(){
        chart.backgroundColor = .gray
        (chart as! testView).drawChartItem()
        let dateStr = "2020-08-13 16:30"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // 2020-08-13 16:30
        
        let convertDate = dateFormatter.date(from: dateStr) // Date 타입으로 변환
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분" // 2020년 08월 13일 오후 04시 30분
        myDateFormatter.locale = Locale(identifier:"ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
        let convertStr = myDateFormatter.string(from: convertDate!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let routine = routine else { return 0}
        return routine.Routine.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = RoutuneAndTodoTable.dequeueReusableCell(withIdentifier: "testCell") as! testCell
        if let routine = routine{
            cell.label.text = routine.Routine[indexPath.row].itemName
            cell.discLabel.text = routine.Routine[indexPath.row].itemDisc
            cell.timeLabel.text = routine.Routine[indexPath.row].start + " ~ " + routine.Routine[indexPath.row].end
        }
        
        return cell
    }
    
    @IBAction func selectDay(_ sender: UIButton) {
        if indexOfOneAndOnlySelectedBtn != nil{
            if !sender.isSelected {
                for unselectIndex in DayBtns.indices {
                    DayBtns[unselectIndex].isSelected = false
                }
                sender.isSelected = true
                indexOfOneAndOnlySelectedBtn = DayBtns.firstIndex(of: sender)
                check = sender.tag
                
            } else {
                sender.isSelected = false
                indexOfOneAndOnlySelectedBtn = nil
                routine = nil
                RoutuneAndTodoTable.reloadData()
                check = 0
            }
            
        } else {
            sender.isSelected = true
            indexOfOneAndOnlySelectedBtn = DayBtns.firstIndex(of: sender)
            check = sender.tag
        }
        if(sender.isSelected){
            print("요일 선택됨")
            getRoutine_reload()
        }
        print(sender.isSelected, indexOfOneAndOnlySelectedBtn ?? 0)
        print("check: \(check)")
        
    }
    func getRoutine_reload(){
        routine = DB.getRoutine((DayBtns[indexOfOneAndOnlySelectedBtn!].titleLabel?.text)!)
        RoutuneAndTodoTable.reloadData()
    }
    func kakaoLogin(){
        
        if (AuthApi.hasToken()) {
            UserApi.shared.accessTokenInfo { (accessTokenInfo , error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //로그인 필요
                        self.kakaoLoginWithKakaoAcc()
                    }
                    else {
                        //기타 에러
                    }
                }
                else {
                    print("이미 로그인 하셨습니다")
                    self.registAcc()
                    
                }
            }
        }
        else {
            //로그인 필요
            self.kakaoLoginWithKakaoAcc()
        }
    }
    
    @IBAction func press_service_out(_ sender: Any) {
        
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
    }
    
    
    func kakaoLoginWithKakaoAcc(){
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoAccount() success.")
                
                //do something
                _ = oauthToken
            }
        }
    }
    
    func registAcc(){
        print("registAcc")
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                
                //do something
                _ = user
                if let userProfile = user?.kakaoAccount?.profile?.profileImageUrl,
                   let userEmail = user?.kakaoAccount?.email{
                    print("userProfile",userProfile)
                    print("userEmail",userEmail)
                    self.postTest(userEmail, userProfile)
                    
                }
                
            }
        }
    }
    
    func postTest(_ email : String, _ profileImg : URL){
        //Toilet: g160j-1618823856
        //let url = "https://ptsv2.com/t/g160j-1618823856/post"
        let urlString = "http://172.20.10.6:8080/"
        var request = URLRequest(url: URL(string: urlString+"api/v1/json")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        // POST 로 보낼 정보
        let params = [ "userID" : email, "profileImgUrl" : profileImg.absoluteString ]
        
        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        AF.request(request).responseString { (response) in
            switch response.result {
            case .success:
                print("POST 성공")
            case .failure(let error):
                print("error : \(error.errorDescription!)")
            }
        }
    }
    
}

extension UIButton {
    var circleButton: Bool {
        set {
            if newValue {
                self.layer.cornerRadius = 0.5 * self.bounds.size.width
                self.clipsToBounds = true
            } else {
                self.layer.cornerRadius = 0
            }
        } get {
            return false
        }
    }
}

class ButtonWithHighlight: UIButton {
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            backgroundColor = UIColor.yellow
            super.isHighlighted = newValue
        }
    }
    
    //    var circleButton: Bool {
    //        set {
    //            if newValue {
    //                self.layer.cornerRadius = 0.5 * self.bounds.size.width
    //                self.clipsToBounds = true
    //            } else {
    //                self.layer.cornerRadius = 0
    //            }
    //        } get {
    //            return false
    //        }
    //    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(backgroundImage, for: state)
    }
    
    
}

class testView: UIView {
    
    //파이차트,,,,
    //음음이건 어떻게 해야 할까
    //추가된 요소를 배열에 집어 넣고
    //한번의 요소 추가가 끝나면 차트를 다시 그리는 식으로 해야겠는걸?
    //
    
    func drawChartItem(
        //        _ startTime : Date, _ endTime : Date
    ){
        let radius = self.frame.height / 2
        
        let center = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        let colors = [UIColor.systemYellow, UIColor.systemGreen, UIColor.systemBlue, UIColor.systemRed,UIColor.white]
        
        
        var startAngle: CGFloat = 0
        var endAngle: CGFloat = 2 * (.pi)
        let path0 = UIBezierPath()
        
        path0.move(to: center)
        path0.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
        colors[4].set()
        path0.fill()
    }
    
    override func draw(_ rect: CGRect) {
        let radius = rect.height / 2
        let center = CGPoint(x: rect.midY, y: rect.midX)
        let colors = [UIColor.systemYellow, UIColor.systemGreen, UIColor.systemBlue, UIColor.systemRed,UIColor.white]
        var startAngle: CGFloat = 0
        var endAngle: CGFloat = 2 * (.pi)
        let path0 = UIBezierPath()
        
        path0.move(to: center)
        path0.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
        colors[4].set()
        path0.fill()
        //
        //        let path1 = UIBezierPath()
        //        startAngle = ( -(.pi) / 2 ) + ( ( -(.pi) / 2) * ( 12 / 24) )
        //        //시작 각도, 사진 참고, 하루의 시작이 오전 12시 -> 12시
        //        endAngle = (.pi * 2) * (1 / 24)
        //        //하루가 24시간이니까 원을 24등분 하고, 할당된 시간 만큼 각도 이동
        //        //즉 하루 24시간중에 1시간짜리 계획이면 1/24
        //        path1.move(to: center)
        //        path1.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
        //        colors[2].set()
        //        path1.fill()
        //
        //        let path2 = UIBezierPath()
        //        startAngle += endAngle + (.pi * 2) * (1 / 24)
        //        endAngle = (.pi * 2) * (1 / 24)
        //        path2.move(to: center)
        //        path2.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
        //        colors[3].set()
        //        path2.fill()
        //
        //        let path3 = UIBezierPath()
        //        startAngle += endAngle + (.pi * 2) * (1 / 24)
        //        endAngle = (.pi * 2) * (1 / 24)
        //        path3.move(to: center)
        //        path3.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
        //        colors[1].set()
        //        path3.fill()
        //
        //
        //
        //        //시간으로 각도 구하기
        //        //12시 = -pi 5/10
        //        //13시 -pi 6/10
        //        //14시 -pi 8 / 10
        //        //15tl -pi
        //
        //        values.enumerated().forEach { (index, value) in
        //            endAngle = (value / total) * (.pi * 2)
        //            print("(value / total) : \((value / total))")
        //            let path = UIBezierPath()
        //            path.move(to: center)
        //            path.addArc(withCenter: center, radius: 100, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
        //            colors[index].set()
        //            path.fill()
        //            startAngle += endAngle
    }
}
/// 체크박스
class CheckBox: UIButton {
    
    /// 체크박스 이미지
    var checkBoxResouces = OnOffResources(
        onImage: UIImage(systemName: DefaultResource.checkedImage),
        offImage: UIImage(systemName: DefaultResource.notCheckedImage)
    ) {
        didSet {
            self.setChecked(isChecked)
        }
    }
    
    enum DefaultResource {
        static let notCheckedImage = "circle"
        static let checkedImage = "checkmark.circle"
    }
    
    /// 체크 상태 변경
    var isChecked: Bool = false {
        didSet {
            guard isChecked != oldValue else { return }
            self.setChecked(isChecked)
        }
    }
    
    /// 이미지 직접 지정 + init
    init(resources: OnOffResources) {
        super.init(frame: .zero)
        self.checkBoxResouces = resources
        commonInit()
    }
    
    /// 일반적인 init + checkBoxResources 변경
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.setImage(checkBoxResouces.offImage, for: .normal)
        
        self.addTarget(self, action: #selector(check), for: .touchUpInside)
        self.isChecked = false
    }
    
    @objc func check(_ sender: UIGestureRecognizer) {
        isChecked.toggle()
    }
    
    /// 이미지 변경
    private func setChecked(_ isChecked: Bool) {
        if isChecked == true {
            self.setImage(checkBoxResouces.onImage, for: .normal)
        } else {
            self.setImage(checkBoxResouces.offImage, for: .normal)
        }
    }
    
    class OnOffResources {
        
        let onImage: UIImage?
        let offImage: UIImage?
        
        init(onImage: UIImage?, offImage: UIImage?) {
            self.onImage = onImage
            self.offImage = offImage
        }
    }
}

