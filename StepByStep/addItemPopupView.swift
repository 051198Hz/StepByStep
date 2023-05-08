//
//  addItemPopupView.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/07.
//

import Foundation
import UIKit
import Alamofire

class AddItemPopupView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ItemTable.dequeueReusableCell(withIdentifier: "testCell") as! testCell
        //cell.label.text = sample[currentTavleView][indexPath.row]
        
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


    override func viewDidLoad() {
        super.viewDidLoad()

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
        if let itemNametext = itemNameText.text, let itemDisc = itemNameText.text, let start = startTime, let endTime = endTime{
            
            let routines : Routines = Routines.init( Routines: [ Routine.init(itemName: itemNametext, itemDisc: itemDisc, start: start.toString(), end: endTime.toString()), Routine.init(itemName: itemNametext, itemDisc: itemDisc, start: start.toString(), end: endTime.toString()) ] )
            
            if let data = try? JSONEncoder().encode(routines) {
                
                print("data = \(String(decoding: data, as: UTF8.self))")
                postTest(data)
            }
            
            
            
        }
        
    }
    
    func postTest(_ data : Data){
        //Toilet: g160j-1618823856
        //let url = "https://ptsv2.com/t/g160j-1618823856/post"
        let urlString = "http://10.2.12.85:8080/"
        var request = URLRequest(url: URL(string: urlString+"api/v1/json")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        request.httpBody = data
        // POST 로 보낼 정보
        
        // httpBody 에 parameters 추가
//        do {
//            try //JSONSerialization.data( withJSONObject : data, options: [])
//        } catch {
//            print("http Body Error")
//        }
        AF.request(request).responseString { (response) in
            
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
    }
    
    
    
}

extension UIDatePicker {
    func toString() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm"
        return formatter3.string(from: self.date)
    }
}
