//
//  addItemPopupView.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/07.
//

import Foundation
import UIKit
import Alamofire
import KakaoSDKUser
import FMDB


class AddItemPopupView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let serverIP = "http://182.214.25.240:8080/"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = data?.Routine.count{
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ItemTable.dequeueReusableCell(withIdentifier: "RoutineCell") as! RoutineCell
        cell.routineItemNameLabel.text = data?.Routine[indexPath.row].itemName
        cell.routineItemDiscLabel.text = data?.Routine[indexPath.row].itemDisc
        cell.routineTimeLabel.text = (data?.Routine[indexPath.row].start)! + " ~ " + (data?.Routine[indexPath.row].end)!
        return cell
    }
    

    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet var DayBtns: [UIButton]!
    
    @IBOutlet var itemNameText: UITextField!
    @IBOutlet var itemDiscText: UITextField!
    @IBOutlet var startTime: UIDatePicker!
    @IBOutlet var endTime: UIDatePicker!
    @IBOutlet var addItemBtn: UIButton!
    
    @IBOutlet var ItemTable: UITableView!
    
    var indexOfOneAndOnlySelectedBtn: Int?
    var check = 0
    var data : Routine?


    override func viewDidLoad() {
        super.viewDidLoad()
        ItemTable.delegate = self
        ItemTable.dataSource = self
        

        acceptBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        for index in DayBtns.indices {
            DayBtns[index].layer.borderWidth = 1.0
            DayBtns[index].layer.borderColor = UIColor.lightGray.cgColor
            DayBtns[index].circleButton = true
            //            DayBtns[index].setBackgroundImage(UIImage(named: "unCheck"), for: .selected)
            //DayBtns[index].setBackgroundImage(UIImage(named: "Check"), for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissView(){
        dismiss(animated: false, completion: nil)
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
                check = 0
            }
        } else {
            sender.isSelected = true
            indexOfOneAndOnlySelectedBtn = DayBtns.firstIndex(of: sender)
            check = sender.tag
        }
        print(sender.isSelected, indexOfOneAndOnlySelectedBtn ?? 0)
        print("check: \(check)")
    }
    
    @IBAction func addItemBtnPressed(_ sender: Any) {
        if( indexOfOneAndOnlySelectedBtn == nil){
            let alert = UIAlertController(title: "알림", message: "요일을 선택하세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [self] action in
            })
            self.present(alert, animated: true, completion: nil)
            return
        }
        if let itemNametext = itemNameText.text,
            let itemDisc = itemNameText.text,
            let start = startTime,
            let endTime = endTime,
            let day =  DayBtns[indexOfOneAndOnlySelectedBtn!].titleLabel?.text{
            //let routines : Routine = Routine.init( Routine: [ RoutineItem.init(itemName: itemNametext, itemDisc: itemDisc, start: start.toString(), end: endTime.toString()), RoutineItem.init(itemName: itemNametext, itemDisc: itemDisc, start: start.toString(), end: endTime.toString()) ] , day : day)
            //data = routines
            let item : RoutineItem = RoutineItem.init(
                itemName: itemNametext,
                itemDisc: itemDisc,
                start: start.toString(),
                end: endTime.toString())
            //테이블뷰에 적재하는 로직 시작
            if(data == nil){
                data = Routine(Routine: [item], day: day)
            }else{
                data?.day = day
                data?.Routine.append(item)
            }
            print("item = ", item)
            ItemTable.reloadData()
            //테이블뷰에 적재하는 로직 끝
            //ItemTable.rowHeight = UITableView.automaticDimension
            //ItemTable.estimatedRowHeight = UITableView.automaticDimension
            print("data = ", data)
            //아이템을 서버로 전송
             if let data = try? JSONEncoder().encode(data) {
                 print("data = \(String(decoding: data, as: UTF8.self))")
                 postTest(data)
             }
        }
    }
    
    func postTest(_ data : Data){
        //let urlString = "http://10.2.12.85:8080/"
        let urlString = serverIP+"api/v1/json"
        
        var request = URLRequest(url: URL(string: serverIP+"api/v1/json")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpBody = data
        
        
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
                    let parameters = ["userID" : userEmail]

                    print("userProfile",userProfile)
                    print("userEmail",userEmail)
                    
                    AF.request(urlString,
                               method: .post,
                               parameters: parameters
                    ).responseString { (response) in
                        /*
                         switch response.result {
                         case .success:
                             print("POST 성공")
                         case .failure(let error):
                             print("error : \(error.errorDescription!)")
                         }
                         */
                        if let JsonParsedData = response.value{
                            //self.posts = JsonParsedData
                            print("json result : ", JsonParsedData)
                            //self.FeedTable.reloadData()
                        }

                    }
                    
                    //self.postTest(profileImg: userProfile, email: userEmail)
                }
                
            }
        }

        
        // POST 로 보낼 정보
        
        // httpBody 에 parameters 추가
//        do {
//            try //JSONSerialization.data( withJSONObject : data, options: [])
//        } catch {
//            print("http Body Error")
//        }
        
    }
    
}

extension UIDatePicker {
    func toString() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm"
        return formatter3.string(from: self.date)
    }
}
