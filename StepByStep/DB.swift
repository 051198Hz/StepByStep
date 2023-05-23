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
    var database:FMDatabase!
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
        database = FMDatabase(url: fileURL)
        
    }
    
    func insertRoutines(){
        
    }
    
    func insertRoutineItem(_ day : String, _ name : String, _ discription : String, _ start_time : String, _ end_time : String){
        guard database.open() else {
            print("Unable to open database")
            return
        }
        do {
            //database.executeUpdate는 next필요없음
            //database.executeQuerys는 next필요함
            try database.executeUpdate("insert into RoutineItem (day, name, discription, date, start_time, end_time ) values (?, ?, ?, ?, ?, ?)", values: [day, name, discription, "test2", start_time, end_time ])
            
            //            let rs = try database.executeQuery("select * from RoutineItem", values: nil)
            //
            //            while rs.next() {
            //                let day = rs.string(forColumn: "day")
            //                let name = rs.string(forColumn:"name")
            //                let discription = rs.string(forColumn: "discription")
            //                let date = rs.string(forColumn: "date")
            //                let start_time = rs.string(forColumn: "start_time")
            //                let end_time = rs.string(forColumn: "end_time")
            //
            //                print("================")
            //                print("day = \(day!)")
            //                print("name = \(name!)")
            //                print("discription = \(discription!)")
            //                print("date = \(date!)")
            //                print("start_time = \(start_time!)")
            //                print("end_time = \(end_time!)")
            //            }
            
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        print("insert routine complete")
        database.close()
    }
    
    
    func getRoutineItem(_ day : String, _ name : String, _ discription : String, _ start_time : String, _ end_time : String){
        
    }
    
    func updateRoutineItem(_ day : String, _ name : String, _ disc : String, _ nameRp : String, _ discRp : String, _ Start : String, _ End : String){
        guard database.open() else {
            print("Unable to open database")
            return
        }
        do {
            //database.executeUpdate는 next필요없음
            //database.executeQuerys는 next필요함
            try database.executeUpdate("update RoutineItem set name = ?, discription = ? , start_time = ?, end_time = ? where day = ? AND name = ? AND discription = ?", values : [nameRp, discRp, Start, End, day, name, disc ])
            
            //            let rs = try database.executeQuery("select * from RoutineItem", values: nil)
            //
            //            while rs.next() {
            //                let day = rs.string(forColumn: "day")
            //                let name = rs.string(forColumn:"name")
            //                let discription = rs.string(forColumn: "discription")
            //                let date = rs.string(forColumn: "date")
            //                let start_time = rs.string(forColumn: "start_time")
            //                let end_time = rs.string(forColumn: "end_time")
            //
            //                print("================")
            //                print("day = \(day!)")
            //                print("name = \(name!)")
            //                print("discription = \(discription!)")
            //                print("date = \(date!)")
            //                print("start_time = \(start_time!)")
            //                print("end_time = \(end_time!)")
            //            }
            
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        print("insert routine complete")
        database.close()
        

    }
    
    func getRoutine(_ day : String) -> Routine{
        let nilitem : RoutineItem = RoutineItem.init(
            itemName: "루틴을 추가해 주세요",
            itemDisc: "⁉️",
            start: "00",
            end: "00")
        let nilday = day
        
        let nilRoutine = Routine(Routine: [nilitem], day: nilday)
        
        var tmp : Routine? = nil
        
        guard database.open() else {
            print("Unable to open database")
            return tmp!
        }
        do{
            let rs = try database.executeQuery("select * from RoutineItem where day = ? order by start_time ASC ",  values: [day])
            
            
            while rs.next(){
                let day = rs.string(forColumn: "day")
                let name = rs.string(forColumn:"name")
                let discription = rs.string(forColumn: "discription")
                let date = rs.string(forColumn: "date")
                let start_time = rs.string(forColumn: "start_time")
                let end_time = rs.string(forColumn: "end_time")
                
                let item : RoutineItem = RoutineItem.init(
                    itemName: name!,
                    itemDisc: discription!,
                    start: start_time!,
                    end: end_time!)
                
                if(tmp == nil){
                    tmp = Routine(Routine: [item], day: day!)
                }else{
                    tmp?.day = day!
                    tmp?.Routine.append(item)
                }
                
                //            let item : RoutineItem = RoutineItem.init(
                //                itemName: name!,
                //                itemDisc: discription!,
                //                start: start_time!,
                //                end: end_time!)
                //
                //            if(tmp == nil){
                //                tmp = Routine(Routine: [item], day: day!)
                //            }else{
                //                tmp?.day = day!
                //                tmp?.Routine.append(item)
                //            }
                
                
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
        if let tmp = tmp {
            return tmp
        }else{
            return nilRoutine
        }
    }
    
    
    func delete(_ day : String, _ name : String, _ disc : String){
        guard database.open() else {
            print("Unable to open database")
            return
        }
        //"select * from RoutineItem where day = ?",  values: [day])
        do {
            print("item del start", day,name,disc)
            try database.executeUpdate("delete from RoutineItem where day = ? AND name = ? AND discription = ? ", values: [day, name, disc])
        }catch {
            print("failed: \(error.localizedDescription)")
        }
        print("item del ended")

        database.close()
    }
    
    
    func test_DBconnect(){
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("create table IF NOT EXISTS RoutineItem(day TEXT, name TEXT, discription TEXT, date text, start_time TEXT, end_time TEXT)", values: nil)
            // 입력시 사용될 녀석.
            //            try database.executeUpdate("insert into info (order_num, badge, date, plus_one, title) values (?, ?, ?, ?, ?)", values: ["1", true, "2012-05-31", true, "사귄날"])
            //try database.executeUpdate("insert into RoutineItem (day, name, discription, date, start_time, end_time ) values (?, ?, ?, ?, ?, ?)", values: ["test", "test", "test", "test", "test", "test" ])
            //
            let rs = try database.executeQuery("select * from RoutineItem", values: nil)
            
            while rs.next() {
                let day = rs.string(forColumn: "day")
                let name = rs.string(forColumn:"name")
                let discription = rs.string(forColumn: "discription")
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
