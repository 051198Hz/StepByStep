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
import Charts

class RoutineAndTodo: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UISheetPresentationControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    var currentTavleView : Int!
    
    @IBOutlet var DayBtns: [UIButton]!
    @IBOutlet var chart: PieChartView!
    
    @IBOutlet var delBoxShowBtn: UIButton!
    
    @IBOutlet var addItemBtn: UIButton!
    
    var indexOfOneAndOnlySelectedBtn: Int?
    var check = 0
    var delBtnChecked : Bool = false
    
    var DB = DAO.shareInstance()
    var routine : Routine?
    var imgFromCam : UIImage?
    
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
        RoutineAndTodoTable.delegate = self
        RoutineAndTodoTable.dataSource = self
        
        kakaoLogin()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("reload")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.getRoutine_reload()
        }

    }
    
    func tableSet(){
        //RoutineAndTodoTable.backgroundColor = UIColor(red: 192, green: 192, blue: 192, alpha: 1)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        RoutineAndTodoTable.addGestureRecognizer(longPress)
//        RoutineAndTodoTable.backgroundColor = UIColor.clear.withAlphaComponent(0)
        
    }
    
    
    @IBOutlet var RoutineAndTodoTable: UITableView!
    @IBOutlet var RoutineTodoSeg: UISegmentedControl!
    
    @IBAction func SwitchRoutuneTodo(_ sender: UISegmentedControl) {
        currentTavleView = sender.selectedSegmentIndex
        getRoutine_reload()
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: RoutineAndTodoTable)
            if let indexPath = RoutineAndTodoTable.indexPathForRow(at: touchPoint) {
                let cell = (RoutineAndTodoTable.cellForRow(at: indexPath)) as! testCell
                if(cell.discLabel.text != "⁉️"){
                    //액션시트로 메뉴 띄욱,, 근데 맘에안듬
                    let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "", message: "Option to select", preferredStyle: .actionSheet)
                    
                    let cancelActionButton = UIAlertAction(title: "완료", style: .default) { _ in
                        print("성공")
                        self.itemDoSuccess()
                    }
                    actionSheetControllerIOS8.addAction(cancelActionButton)
                    
                    let saveActionButton = UIAlertAction(title: "실패", style: .default)
                    { _ in
                        print("실패")
                        self.itemDoFailed(cell)
                    }
                    actionSheetControllerIOS8.addAction(saveActionButton)
                    
                    let deleteActionButton = UIAlertAction(title: "수정", style: .default)
                    { _ in
                        self.itemEdit(cell: cell)
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
    
    
    @IBAction func delBoxShowBtnPressed(_ sender: Any) { //셀 삭제박스 활성화
        let firstIdx = IndexPath(row: 0, section: 0)
        
        if(RoutineAndTodoTable.visibleCells.isEmpty || ((RoutineAndTodoTable.cellForRow(at: firstIdx) as! testCell).discLabel.text == "⁉️") ){//삭제불가
            let alert = UIAlertController(title: "알림", message: "삭제할수 있는 항목이 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [self] action in
            })
            self.present(alert, animated: true, completion: nil)
            return
        }
        if(delBtnChecked == false){//처음 삭제버튼 클릭
            for cell  in RoutineAndTodoTable.visibleCells {
                (cell as! testCell).delCehckBox.isHidden = false
            }
            delBtnChecked = true
        }else{//삭제더블체크
            let alert = UIAlertController(title: "알림", message: "정말 삭제하시겠습니까??", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .default) { [self] action in
                //취소처리...
                
                
                for cell in RoutineAndTodoTable.visibleCells {
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
                for cell in RoutineAndTodoTable.visibleCells{
                    let delCell = (cell as! testCell)
                    if(delCell.delCehckBox.isChecked){
                        let delIdx = RoutineAndTodoTable.indexPath(for: cell)
                        idxs.append(delIdx!)
                        DB.delete((DayBtns[indexOfOneAndOnlySelectedBtn!].titleLabel?.text)!, delCell.nameLabel.text!, delCell.discLabel.text!)
                    }
                }
                print("삭제 대상 : ", idxs)
                for item in idxs{
                    let item = item as IndexPath
                    print("행 : ", item.row)
                    print("섹션 : " , item.section)
                }
                
                //RoutuneAndTodoTable.deleteRows(at: idxs, with: .fade)
                
                for cell  in RoutineAndTodoTable.visibleCells {
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
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
        
    }
    
    func itemtodata(){
        
            
        
        let calendar = Calendar.current
        let items = DB.getRoutine((DayBtns[indexOfOneAndOnlySelectedBtn!].titleLabel?.text)!).Routine
        
        var labels = [String]()
        var datas = [Double]()
        var i = 0
        var space = 0
        var idx = 0
        
        while i <= 1440 {
            if(i == 1440){
                datas.append(Double(space))
                labels.append("")
            }
            if (items[idx].start.toDate(withFormat: "HH:mm") == nil) {
                chart.clear()
                return
            }
            
            let comp = calendar.dateComponents( [.hour, .minute], from: items[idx].start.toDate(withFormat: "HH:mm")!)
            
            let hour = comp.hour ?? 0
            let minute = comp.minute ?? 0
            let finalMinut:Int = (hour * 60) + minute
            
            let comp2 = calendar.dateComponents([.hour, .minute], from: items[idx].end.toDate(withFormat: "HH:mm")!)
            let hour2 = comp2.hour ?? 0
            let minute2 = comp2.minute ?? 0
            let finalMinut2:Int = (hour2 * 60) + minute2
            
            if( i == finalMinut){
                datas.append( Double(space) )
                space = 0
                labels.append("")
                let name = items[idx].itemName
                let desc = items[idx].itemName
                let start = items[idx].start
                let end = items[idx].end
                
                labels.append( name
                              // + "\n" + desc + "\n" + start + "~" + end
                )
                datas.append(Double(finalMinut2 - finalMinut))
                i = finalMinut2
                if( (idx + 1) < items.count){
                    idx += 1
                }
            }
            space += 1
            i += 1
        }
        
        print("labels : ",labels )
        print("datas : ", datas )
        
        setChart(dataPoints: labels, values: datas)

    }
    
    func setChart(){
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        chart.rotationEnabled = false
        chart.highlightPerTapEnabled = false

        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry1 = PieChartDataEntry(value: values[i], label: dataPoints[i] , data:  dataPoints[i] as AnyObject)
          dataEntries.append(dataEntry1)
        }
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "Units Sold")
        pieChartDataSet.drawValuesEnabled = false
        //pieChartDataSet.valueLinePart1Length = 0.4
        //pieChartDataSet.valueLinePart2Length = 0
        //pieChartDataSet.xValuePosition = .outsideSlice
        pieChartDataSet.valueTextColor = .black
        let pieChartData = PieChartData(dataSet: pieChartDataSet)

        chart.data = pieChartData
        chart.legend.enabled = false
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count {
          let red = Double(arc4random_uniform(156)+100)
          let green = Double(arc4random_uniform(56)+200)
          let blue = 255
            
          let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            
          colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
      }
    
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(currentTavleView == 0){
            guard let routine = routine else { return 0}
            
            return routine.Routine.count
        }else{
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell") as! testCell
        cell.layer.cornerRadius = 10
        
        if(currentTavleView == 0){
            if let routine = routine{
                cell.nameLabel.text = routine.Routine[indexPath.row].itemName
                cell.discLabel.text = routine.Routine[indexPath.row].itemDisc
                cell.timeLabel.text = routine.Routine[indexPath.row].start + " ~ " + routine.Routine[indexPath.row].end
                cell.selectionStyle = .none

            }
            
        }else{
            
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
                RoutineAndTodoTable.reloadData()
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
        if let indexOfOneAndOnlySelectedBtn = indexOfOneAndOnlySelectedBtn{
            routine = DB.getRoutine((DayBtns[indexOfOneAndOnlySelectedBtn].titleLabel?.text)!)
            RoutineAndTodoTable.reloadData()
            itemtodata()
        }

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
    
    func itemDoSuccess(){
        openCam()
    }
    func itemDoFailed( _ cell : testCell){
        
        DB.delete((DayBtns[indexOfOneAndOnlySelectedBtn!].titleLabel?.text)! , cell.nameLabel.text!, cell.discLabel.text!)
        
    }
    func itemEdit(cell : testCell){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditItemView") as! EditItemVC
        
        vc.name = cell.nameLabel.text;
        vc.disc = cell.discLabel.text;
        vc.time = cell.timeLabel.text;
        vc.day = (DayBtns[indexOfOneAndOnlySelectedBtn!].titleLabel?.text)!
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    func openCam(){
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.allowsEditing = true //정방향으로 편집
        camera.cameraDevice = .rear
        camera.cameraCaptureMode = .photo
        camera.delegate = self
        present(camera, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {//사진 찍었을 때
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imgFromCam  = image
            //서버로 이미지 업로드
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //사진 캔슬했을 때
            picker.dismiss(animated: true, completion: nil)
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
    
    override func draw(_ rect: CGRect) {
        
        print("draw")
        
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
//        values.enumerated().forEach { (index, value) in
//            endAngle = (value / total) * (.pi * 2)
//            print("(value / total) : \((value / total))")
//            let path = UIBezierPath()
//            path.move(to: center)
//            path.addArc(withCenter: center, radius: 100, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
//            colors[index].set()
//            path.fill()
//            startAngle += endAngle
//        }
        
        
        
//        values.enumerated().forEach { (index, value) in
//            endAngle = (value / total) * (.pi * 2)
//            print("(value / total) : \((value / total))")
//            let path = UIBezierPath()
//            path.move(to: center)
//            path.addArc(withCenter: center, radius: 100, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
//            colors[index].set()
//            path.fill()
//            startAngle += endAngle
//        }
        
        
        let time1 : String = "6:30"
        let start = time1.split(separator : ":")
        let time2 : String = "12:00"
        let end = time2.split(separator : ":")
        
        let dateTime1 = time1.toDate(withFormat: "HH:mm")!
        let dateTime2 = time2.toDate(withFormat: "HH:mm")!
        
        let timeSub = dateTime2.timeIntervalSince(dateTime1) / 60
        
        let path1 = UIBezierPath()
        print("start", start)
        print("end", end)
        let zeroPoint : CGFloat = (-(.pi) / 2)
        let startHtoM : CGFloat = CGFloat( ( start[0] as NSString).floatValue  * 60)
        let startMtoM : CGFloat = CGFloat( ( start[1] as NSString).floatValue)
        
        startAngle = zeroPoint + ( ( .pi * 2) * ( (  startHtoM + startMtoM ) / 1440) )

        let endHtoM : CGFloat = CGFloat((end[0] as NSString).floatValue * 60)
        let endMtoM : CGFloat = CGFloat(( end[1] as NSString).floatValue)
        
        endAngle = ( (.pi) * 2 *  ( (  timeSub ) / 1440) )
        //하루가 24시간이니까 원을 24등분 하고, 할당된 시간 만큼 각도 이동
        //즉 하루 24시간중에 1시간짜리 계획이면 1/24
        path1.move(to: center)
        path1.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + endAngle, clockwise: true)
        colors[1].set()
        path1.fill()
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
//        }
        
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

