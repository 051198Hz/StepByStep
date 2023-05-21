//
//  ViewController.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/15.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
 
    @IBOutlet var imageView: UIImageView!
    var img : UIImage?
    
    @IBOutlet var btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnpressed(_ sender: Any) {
        postTest("peeper_o_o@naver.com")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func postTest(_ email : String){
        //Toilet: g160j-1618823856
        //let url = "https://ptsv2.com/t/g160j-1618823856/post"
        img = UIImage(named: "img")!
        imageView.image = img
        let data = img!.jpegData(compressionQuality: 0.9)
        let comment = "greeting"
        let urlString =
    "http://182.214.25.240:8080/api/v1/memoir?email=ys4512558@naver.com&comment=hihihihi"
        
        //"http://182.214.25.240:8080/api/v1/memoir?email=" + email + "&comment=" + comment
//        var request = URLRequest(url: URL(string: urlString)!)
//
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.timeoutInterval = 10
//        // POST 로 보낼 정보
//    let params = [ "userID" : email, "profileImgUrl" : profileImg.absoluteString ]
//
//        // httpBody 에 parameters 추가
//        do {
//            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
//        } catch {
//            print("http Body Error")
//        }
//        AF.request(request).responseString { (response) in
//            switch response.result {
//            case .success:
//                print("POST 성공")
//            case .failure(let error):
//                print("error : \(error.errorDescription!)")
//            }
//        }
        
        
        let header : HTTPHeaders = [
            "Content-Type" : "multipart/form-data",
        ]
        AF.upload(multipartFormData: { multipartFormData in
            do{
                let AudioFile = try data
                multipartFormData.append( AudioFile! ,//AudioFile as Data, // the audio as Data
                                             withName: "image", // nodejs-> multer.single('mp3')
                                             fileName: "file.jpeg", // name of the file
                                             mimeType: "image/jpeg")
            }catch{
                print("error ocurred")
            }
               }, to: urlString, method: .post, headers: header ).uploadProgress(queue: .main, closure: { progress in
                   //Current upload progress of file
                   print("Upload Progress: \(progress.fractionCompleted)")
               })
            .responseString { (response) in
                switch response.result {
                case .success:
                    print("POST 성공")
                case .failure(let error):
                    print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                }
            }
        
        
        
    }
    

}
