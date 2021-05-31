//
//  ViewController.swift
//  splitflap-stockapp
//
//  Created by Samuel Hoffmann on 5/7/21.
//  Copyright © 2021 Samuel Hoffmann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var bodyView: UIView!
    
    let splitFlapHeight = 50
    var splitFlapWidth = 0
    let padding = 3
    var numRows = 0
    
    var splitflapViewList : [StockTileView] = []
    var stocks : [Stock] = []
    var textCapture = UITextField()
    var displayList : [Stock] = []
    var index = 0
    var splitDisplayButtons : [UIButton] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Data Reset:
//        UserDefaults.standard.set(getStockString(), forKey: "SavedStocks")
        
        // laod saved data
        let savedStocksString = UserDefaults.standard.value(forKey: "SavedStocks") as? String ?? ""
        let items = savedStocksString.split(separator: ",")
        if !items.isEmpty{
            for stockStr in items{
                print(stockStr)
                self.stocks.append(Stock(symbol: String(stockStr)))
            }
        }
        
        splitFlapWidth = Int(floor(Double(self.bodyView.frame.width)))
        numRows = Int(floor(Double((self.bodyView.frame.height / 53))))
        
        if !stocks.isEmpty{
            for stockNum in 0...stocks.count-1{
                if stockNum <= numRows-1{
                    displayList.append(stocks[stockNum])
                }
            }
        }
        
        self.view.layoutIfNeeded()
        
        
        for rowNum in 0...numRows-1{
            if stocks.count-1 >= rowNum{
                let splitflapViewTemp = StockTileView(frame: CGRect(x: padding, y: ((padding)*(rowNum+1))+(splitFlapHeight*(rowNum)), width: (splitFlapWidth - (padding*2)), height: splitFlapHeight), stock: displayList[rowNum])
                splitflapViewTemp.controller = self
                splitflapViewList.append(splitflapViewTemp)
                self.bodyView.addSubview(splitflapViewTemp)
            }else{
                let splitflapViewTemp = StockTileView(frame: CGRect(x: padding, y: ((padding)*(rowNum+1))+(splitFlapHeight*(rowNum)), width: (splitFlapWidth - (padding*2)), height: splitFlapHeight))
                splitflapViewTemp.controller = self
                splitflapViewList.append(splitflapViewTemp)
                self.bodyView.addSubview(splitflapViewTemp)
            }
            
            let buttonTemp = UIButton(frame:
                CGRect(x: Int(CGFloat(9)*(CGFloat((splitFlapWidth - (padding*2)))/CGFloat(10))),
                       y: ((padding)*(rowNum+1))+(splitFlapHeight*(rowNum)),
                       width: (splitFlapWidth - (padding*2))/Int(CGFloat(10)),
                       height: splitFlapHeight))
            buttonTemp.addTarget(self, action: #selector(editButtonClicked), for: .touchUpInside)
            buttonTemp.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            splitDisplayButtons.append(buttonTemp)
            self.bodyView.addSubview(buttonTemp)
            
            
        }
        
        
        
        let footer = FooterView(frame: CGRect(x: CGFloat(padding), y: 0, width: self.footerView.frame.width-CGFloat((padding*2)), height: CGFloat(splitFlapHeight)))
        footer.controller = self
        self.footerView.addSubview(footer)
        
        
        
        let header = HeaderView(frame: CGRect(x: CGFloat(padding), y: CGFloat(padding*3), width: self.headerView.frame.width-CGFloat((padding*2)), height: CGFloat(splitFlapHeight)))
        header.controller = self
        self.headerView.addSubview(header)
        
        textCapture.alpha = 0
        textCapture.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        textCapture.keyboardAppearance = .dark
        textCapture.autocorrectionType = .no
        textCapture.keyboardType = .asciiCapable
        textCapture.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textCapture.addTarget(self, action: #selector(textDone), for: .editingDidEndOnExit)
        self.view.addSubview(textCapture)
        
        //keyabord notificaiton
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        
        
        
        
        
        self.view.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 53/255, alpha: 100)
        self.bodyView.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 53/255, alpha: 100)
        self.footerView.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 53/255, alpha: 100)
        self.headerView.backgroundColor = UIColor(red: 52/255, green: 52/255, blue: 53/255, alpha: 100)
        // Set the text to display by animating the flaps
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            for flap in self.splitflapViewList{
                flap.refresh(force: true)
            }
            let header = self.headerView.subviews[0] as! HeaderView
            header.refresh()
            let footer = self.footerView.subviews[0] as! FooterView
            footer.refresh()
            if self.stocks.count > self.splitDisplayButtons.count{
                footer.setState(state: (footer.getState() == FooterState.done || footer.getState() == FooterState.done_up) ? .done_up : .edit_up)
            }
        }
    }
    
    func refresh() {
        for flap in self.splitflapViewList{
            flap.refresh(force: true)
        }
    }
    

    func editOn(){
        let header = self.headerView.subviews[0] as! HeaderView
        let footer = self.footerView.subviews[0] as! FooterView
        
        footer.setState(state: self.stocks.count > 13 ? .done_up : .done)
        header.setState(state: header.getState() == HeaderState.refresh_down ? .add_down : .add)
        
        for flap in self.splitflapViewList{
            flap.setState(state: .edit)
        }
    }
    
    func editOff(){
        let header = self.headerView.subviews[0] as! HeaderView
        let footer = self.footerView.subviews[0] as! FooterView
        
        footer.setState(state: self.stocks.count > 13 ? .edit_up : .edit)
        header.setState(state: header.getState() == HeaderState.refresh_down ? .refresh_down : .refresh)
        
        for flap in self.splitflapViewList{
            flap.setState(state: .display)
        }
    }
    
    func getStockString() -> String{
        var tmp = ""
        for stock in stocks{
            tmp += ","+stock.getTicker()
        }
        if tmp.distance(from: tmp.startIndex, to: tmp.firstIndex(of: ",") ?? tmp.startIndex) > 0{
            tmp.remove(at: tmp.firstIndex(of: ",")!)
        }
        return tmp
    }
    
    
    func addStock(){
        textCapture.becomeFirstResponder()
        textCapture.text!.removeAll()
        //set up text view for text changes
//        let splitflapViewTemp = StockTileView(frame: CGRect(x: padding, y: ((padding)*(rowNum+1))+(splitFlapHeight*(rowNum)), width: (splitFlapWidth - (padding*2)), height: splitFlapHeight))
//
//        splitflapViewTemp.controller = self
//        splitflapViewList.append(splitflapViewTemp)
//        self.bodyView.addSubview(splitflapViewTemp)
//        splitflapViewList[0].
    }
    
    func removeStock(stock: Stock){
        for mainStock in 0...stocks.count-1{
            if stocks[mainStock].getTicker() == stock.getTicker(){
                stocks.remove(at: mainStock)
                
                break
            }
        }
        for flap in splitflapViewList{
            if flap.getStock().getTicker() == stock.getTicker(){
                flap.clearStock()
            }
        }
        UserDefaults.standard.set(getStockString(), forKey: "SavedStocks")
        updateDisplay()
    }
    
    @objc func editButtonClicked(_ sender: UIButton){
//        print("button clicked")
        let index = splitDisplayButtons.firstIndex(of: sender)!
        let splitflap = splitflapViewList[index]
        if splitflap.getState() == .edit && splitflap.getStock().getTicker() != ""{
            splitflap.clearStock()
            removeStock(stock: splitflap.getStock())
        }
    }
    
    func updateDisplay(){
        if stocks.isEmpty{return}
        displayList.removeAll()
        var countIndex = 0
        for stockIndex in index...stocks.count-1{
            if displayList.count < numRows{
                displayList.append(stocks[stockIndex])
                splitflapViewList[countIndex].setStock(stock: stocks[stockIndex])
            }
            countIndex += 1
        }
        if  displayList.count < splitflapViewList.count{
            if splitflapViewList[displayList.count-1].getStock().getTicker() == splitflapViewList[displayList.count].getStock().getTicker(){
                splitflapViewList[displayList.count].clearStock()
            }
        }
        
        let header = self.headerView.subviews[0] as! HeaderView
        let footer = self.footerView.subviews[0] as! FooterView
        if stocks.count > splitDisplayButtons.count{//turn on footer arrow
            footer.setState(state: (footer.getState() == FooterState.done || footer.getState() == FooterState.done_up) ? .done_up : .edit_up)
        }
        if index > 0{//turn on header arrow
            header.setState(state: (header.getState() == HeaderState.add || header.getState() == HeaderState.add_down) ? .add_down : .refresh_down)
        }
        if index == 0{//turn off header arrow
            header.setState(state: (header.getState() == HeaderState.add || header.getState() == HeaderState.add_down) ? .add : .refresh)
        }
        if index == (stocks.count - splitDisplayButtons.count){//turn off footer arrow
            footer.setState(state: (footer.getState() == FooterState.done || footer.getState() == FooterState.done_up) ? .done : .edit)
        }
    }
    
    func shiftUp(){
        if index < (stocks.count - splitDisplayButtons.count){
            index += 1
            updateDisplay()
        }
    }
    
    func shiftDown(){
        if index > 0{
            index -= 1
            updateDisplay()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            //adjust stocks to show the lowest in the list
        }
    }
    
    @objc func textChanged(_ sender: UITextField){
        //update text in cell per typing
        let header = self.headerView.subviews[0] as! HeaderView
        if sender.text!.count > 8{
            sender.text!.removeLast()
        }
        sender.text! = sender.text!.uppercased()
        let displayText = sender.text! + String(repeating: " ", count: 10-(sender.text!.count+2)) + " ⊕"
        header.setText(text: displayText, animated: true)
    }
    @objc func textDone(_ sender: UITextField){
        //validate and close responder
        let header = self.headerView.subviews[0] as! HeaderView
        // check for duplicate
        var duplicateFound = false
        for stockTMP in stocks{
            if stockTMP.getTicker() == sender.text!.uppercased(){
                duplicateFound = true
                break
            }
        }
        
        if !duplicateFound && !sender.text!.isEmpty && Stock.isStock(sender.text!) {
            sender.text! = sender.text!.uppercased()
            let newStock = Stock(symbol: sender.text!)
            stocks.append(newStock)
            header.setText(text: "         ⊕", animated: false)
            UserDefaults.standard.set(getStockString(), forKey: "SavedStocks")
            
            if stocks.count > splitDisplayButtons.count{
                for _ in 0...(stocks.count-splitDisplayButtons.count){
                    shiftUp()
                }
            }else{
                updateDisplay()
            }
            sender.resignFirstResponder()
        }else{
            sender.text!.removeAll()
            header.setText(text: "*INVALID**", animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                header.setText(text: "         ⊕", animated: false)
                sender.resignFirstResponder()
            }
        }
    }
    

}

