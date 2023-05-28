//
//  EditItemVC.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/21.
//

import UIKit
import Alamofire
import KakaoSDKUser

class EditItemVC: UIViewController {

    
    let serverIP = "http://182.214.25.240:8080/"

    
    
    var name : String!
    var disc : String!
    var time : String!
    var day : String!
    let DB = DAO.shareInstance()

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var discTextField: UITextField!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    @IBOutlet weak var editCompetBtn: UIButton!
    @IBOutlet weak var editCancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = name
        discTextField.text = disc
        let time = time!.split(separator: "~")
        if let start = time[0].description.toDate(withFormat: "HH:mm"), let end = time[1].description.toDate(withFormat: "HH:mm"){
            startTimePicker.date = start
            endTimePicker.date = end
        }

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func completBtnPressed(_ sender: Any) {
        if let nameRp = nameTextField.text, let discRp = discTextField.text{
            DB.updateRoutineItem(day, name, disc, nameRp, discRp , startTimePicker.toString(), endTimePicker.toString())
        }
        dismiss(animated: true)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
    }
    
    
    

}

extension String {
    
    func toDate(withFormat format: String = "HH:mm")-> Date?{

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "kr")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)

        return date

    }
    
    
}
