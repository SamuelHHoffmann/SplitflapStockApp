//
//  StockTileView.swift
//  splitflap-stockapp
//
//  Created by Samuel Hoffmann on 5/8/21.
//  Copyright © 2021 Samuel Hoffmann. All rights reserved.
//

import Foundation
import UIKit

enum StockState {
    case display
    case edit
}

class StockTileView: UIView, SplitflapDataSource, SplitflapDelegate {
    
    private var numberOfFlaps = 10
    
    func numberOfFlapsInSplitflap(_ splitflap: Splitflap) -> Int {
        return numberOfFlaps
    }
    func tokensInSplitflap(_ splitflap: Splitflap) -> [String] {
      return "* ABCDEFGHIJKLMNOPQRSTUVWXYZ:$-+.0123456789⊕⊖".map { String($0) }
    }
    func splitflap(_ splitflap: Splitflap, builderForFlapAtIndex index: Int) -> FlapViewBuilder {
      return FlapViewBuilder { builder in
        builder.backgroundColor = UIColor(red: 62/255, green: 62/255, blue: 64/255, alpha: 1)
        builder.cornerRadius    = 2.5
        builder.font            = UIFont(name: "Avenir-Black", size:45)
        builder.textAlignment   = .center
        builder.textColor       = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.75)
        builder.lineColor       = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 100)
      }
    }
    
    
    private var splitFlapDisplay = Splitflap()
    private var text = ""
    private var stock = Stock()
    private var stop = false
    var controller = ViewController()
    private var state : StockState = .display
//    private var buttons : [UIButton] = []
    
    override init(frame: CGRect) {
        
        splitFlapDisplay = Splitflap(frame: frame)
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        splitFlapDisplay.datasource = self
        splitFlapDisplay.delegate = self
        self.addSubview(splitFlapDisplay)
        
        
        
        self.text = "          "
        splitFlapDisplay.setText(self.text, animated: false)
        
//        self.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 53/255, alpha: 100)
//        self.backgroundColor = UIColor.purple
        
        
        
        
    }
    
    init(frame: CGRect, stock: Stock) {
        
        splitFlapDisplay = Splitflap(frame: frame)
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        splitFlapDisplay.datasource = self
        splitFlapDisplay.delegate = self
        self.addSubview(splitFlapDisplay)
        

            
        self.stock = stock
        self.text = (self.stock.isStock() ? self.stock.getTicker() + " " + String(self.stock.getValue()) : "")
        self.splitFlapDisplay.setText(self.text, animated: true)
        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func setStock(stock: Stock){
        self.stock = stock
        refresh(force:true)
    }
    func getStock() -> Stock{
        return self.stock
    }
    func clearStock(){
        self.stock.setStock(symbol: "")
        self.text = "          "
        splitFlapDisplay.setText(self.text, animated: false)
    }
    
    func setText(text: String, animated: Bool){
        splitFlapDisplay.setText(text, animated: animated)
    }
    
    func getState() -> StockState{
        return self.state
    }
    func setState(state: StockState){
        self.state = state
        refresh(force:true)
    }
    
    func stopRefresh(){
        self.stop = true
    }
    func refresh(force: Bool){
//        self.setText(text: "**********", animated: false)
        if force{
            self.stop = false
        }
        let isStock = self.stock.isStock()
        let ticker = self.stock.getTicker()
        let value = self.stock.getValue()
        let change = self.stock.getChange()
        if self.state == .display{
            self.text = (isStock ?
            self.stock.getTicker() +
                String(repeating: " ", count: (10-(ticker.count+String(value).count) <= 0) ? 1 : 10-(ticker.count+String(value).count)) +
            String(value)
                : "          ")
            self.splitFlapDisplay.setText(self.text, animated: true, completionBlock: {
                if self.stop{
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.text = (isStock ?
                    self.stock.getTicker() +
                        String(repeating: " ", count: (10-(ticker.count+String(change).count) <= 0) ? 1 : 10-(ticker.count+String(change).count)) +
                        (change < 0 ? String(change) : "+"+String(change))
                        : "          ")
                    self.splitFlapDisplay.setText(self.text, animated: true, completionBlock: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            self.stop = true
                            self.refresh(force:false)
                        }
                    })
                }
            })
        }else if self.state == .edit{
            self.text = ticker + String(repeating: " ", count:10-(ticker.count+1)) + (ticker == "" ? " " : "⊖")
            self.splitFlapDisplay.setText(self.text, animated: true)
        }
    }
    
    
//    @objc func buttonTouched(_ sender: UIButton){
//        print("click")
//        if state == .edit{
//            if buttons.firstIndex(of: sender)! == 9{
//                print("Remove Stock")
//                controller.removeStock(stock: self.stock)
//            }
//        }
//    }

}
