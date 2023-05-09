//
//  DB.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/09.
//

import Foundation
import UIKit
import FMDB
 
class DAO: NSObject {
    // #. 싱글턴 객체 정의
    struct staticInstance {
        static var instance: DAO?
    }
    // 1. FMDB 정의
    var db:FMDatabase!
    let fileManager:FileManager = FileManager.default
    
    //MARK:-
    //MARK:- #. 클래스 함수 생성
    class func shareInstance() ->(DAO) {
        if (staticInstance.instance == nil) {
            staticInstance.instance = DAO()
            staticInstance.instance?.initData()
        }
        
        return staticInstance.instance!
    }
    
    //MARK:-
    //MARK:- 1. 기본적인 데이터를 확인하고 생성한다.
    func initData() {
        // 1. doc 폴더 만들기.
        let documentsPath1 = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let logsPath = documentsPath1.appendingPathComponent("doc")
        print(logsPath!)
        do {
            try FileManager.default.createDirectory(atPath: logsPath!.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        // 2. 해당 폴더에 sqlite 생성해주기.
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("doc/Stepbystep.sqlite")
        
        // FMDB 쓸때 기존에 파일을 만들어서 생성한 다음에 오픈을 해주었는데,
        // 이렇게 만들지 않은 상태에서 URL 로 생성 하니
        // 없으면 자동으로 생성해서 열어주고
        // 있으면 있는거 열어줌.
        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        do {
            try database.executeUpdate("create table IF NOT EXISTS RoutineItem(day TEXT, name TEXT, discription TEXT, date text, start_time TEXT, end_time TEXT)", values: nil)
            // 입력시 사용될 녀석.
//            try database.executeUpdate("insert into info (order_num, badge, date, plus_one, title) values (?, ?, ?, ?, ?)", values: ["1", true, "2012-05-31", true, "사귄날"])
            try database.executeUpdate("insert into RoutineItem (day, name, discription, date, start_time, end_time ) values (?, ?, ?, ?, ?, ?)", values: ["test", "test", "test", "test", "test", "test" ])
//
            let rs = try database.executeQuery("select * from RoutineItem", values: nil)
            while rs.next() {
                let day = rs.string(forColumn: "day")
                let name = rs.string(forColumn:"name")
                let discription = rs.string(forColumn: "ßdiscription")
                let date = rs.string(forColumn: "date")
                let start_time = rs.string(forColumn: "start_time")
                let end_time = rs.string(forColumn: "end_time")
                
                print("================")
                print("day = \(day!)")
                print("name = \(name!)")
                print("discription = \(discription!)")
                print("date = \(date!)")
                print("start_time = \(start_time!)")
                print("end_time = \(end_time!)")
            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
}
