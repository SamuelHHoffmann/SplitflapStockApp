//
//  Stock.swift
//  splitflap-stockapp
//
//  Created by Samuel Hoffmann on 5/8/21.
//  Copyright © 2021 Samuel Hoffmann. All rights reserved.
//

import Foundation

class Stock {
    
    private var tickerSymbol = ""
    private var value = 0.00
    private var change = 0.00
    private var date = Date()
    private var calendar = Calendar.current
//    private var lastChangedTime_hour = 0
    private var lastChangedTime_min = 0
    private var lastJson : [[String: Any]] = []
    private var valid : Bool = false
    
    static var busy : Bool = false
    
    func setStock(symbol: String){
        if symbol == ""{
            // reset stock values to default
            resetStock()
            return
        }
        
        if Stock.isStock(symbol){
            valid = true
            tickerSymbol = symbol
            setValue()
        }
    }
    
    private func resetStock(){
        self.value = 0.00
        self.change = 0.00
        self.tickerSymbol = ""
        self.valid = false
    }
    
    func getValue() -> Double{
//        if lastChangedTime_min >= 15 {
//            setValue()
//        }
        return value
    }
    
    func getTicker() -> String{
        return tickerSymbol
    }
    
    func getChange() -> Double{
        return change
    }
    
    private func setValue() {
//        self.value = 28.19
//        self.change = -12.65
//        return
        
        let json = Stock.sendAPIRequest(self.tickerSymbol)
        
        self.value = json[0]["price"]! as! Double
        self.change = json[0]["changes"]! as! Double

//        lastChangedTime_hour = calendar.component(.hour, from: date)
        lastChangedTime_min = calendar.component(.minute, from: date)
    }
    
    
    
    init(symbol: String) {
        setStock(symbol: symbol)
    }
    
    init(){
        //default init
    }
    
    static func isStock(_ symbol: String) -> Bool{
//        return true
        
        let json = Stock.sendAPIRequest(symbol)
        
        if json.isEmpty{
            return false
        }
        return true
    }
    
    func isStock() -> Bool {
        return self.valid
    }
    
    static func sendAPIRequest(_ symbol: String)->[[String: Any]]{
        let url = URL(string: "https://financialmodelingprep.com/api/v3/profile/"+symbol+"?apikey=698f292ae31afc4a04bdca3322c9067a")

        var request = URLRequest(url: url!)
        let sema = DispatchSemaphore.init(value: 0)
        var responseJSON : [[String: Any]] = []
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            defer { sema.signal() }
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }

//            print(symbol)
            let json = try! (JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]])
            
            responseJSON = json
            
        }
        task.resume()
        sema.wait()

        return responseJSON
    }

    
    
}

