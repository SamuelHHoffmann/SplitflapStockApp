//
//  FooterView.swift
//  splitflap-stockapp
//
//  Created by Samuel Hoffmann on 5/9/21.
//  Copyright © 2021 Samuel Hoffmann. All rights reserved.
//

import Foundation
import UIKit

enum FooterState {
    case uninit
    case edit
    case edit_up
    case done
    case done_up
}

class FooterView: UIView, SplitflapDataSource, SplitflapDelegate {
    private var tokensString = "*abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ:$-+.0123456789↺↻⊕⊖↑↓ "
    private var numberOfFlaps = 10
    
    func numberOfFlapsInSplitflap(_ splitflap: Splitflap) -> Int {
        return numberOfFlaps
    }
    func tokensInSplitflap(_ splitflap: Splitflap) -> [String] {
      return tokensString.map { String($0) }
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
//    var stock = Stock()
    private var buttons : [UIButton] = []
    private var state : FooterState = .uninit
    var controller = ViewController()
    
    
    override init(frame: CGRect) {
        
        
        splitFlapDisplay = Splitflap(frame: frame)
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        splitFlapDisplay.datasource = self
        splitFlapDisplay.delegate = self
        self.addSubview(splitFlapDisplay)
        
        self.text = "      Edit"
        splitFlapDisplay.setText(self.text, animated: false)
        self.state = .edit
        
        for x in 0...numberOfFlaps-1{
            let buttonTemp = UIButton(frame: CGRect(x: CGFloat(x)*(frame.width/CGFloat(numberOfFlaps)), y: 0, width: frame.width/CGFloat(numberOfFlaps), height: frame.height))
            buttonTemp.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
            buttonTemp.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            buttons.append(buttonTemp)
            self.addSubview(buttonTemp)
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func setText(text: String, animated: Bool){
        splitFlapDisplay.setText(text, animated: animated)
    }
    
    func refresh(){
        self.text = "**********"
        splitFlapDisplay.setText(self.text, animated: false)
        self.text = "      Edit"
        splitFlapDisplay.setText(self.text, animated: true)
    }
    

    func setState(state: FooterState){
        switch state {
        case .edit:
            self.text = "      Edit"
        case .done:
            self.text = "      Done"
        case .edit_up:
            self.text = "↓     Edit"
        case .done_up:
            self.text = "↓     Done"
        case .uninit:
            self.text = "**********"
        }
        self.state = state
        splitFlapDisplay.setText(self.text, animated: true)
    }
    
    func getState() -> FooterState {
        return state
    }
    
    
    
    @objc func buttonTouched(_ sender: UIButton){
        if state == .done{
            if buttons.firstIndex(of: sender)! >= 6{
                controller.editOff()
            }
        }else if state == .done_up{
            if buttons.firstIndex(of: sender)! >= 6{
                controller.editOff()
            }else if buttons.firstIndex(of: sender)! == 0{
                controller.shiftUp()
            }
        }else if state == .edit{
            if buttons.firstIndex(of: sender)! >= 6{
                controller.editOn()
            }
        }else if state == .edit_up{
            if buttons.firstIndex(of: sender)! >= 6{
                controller.editOn()
            }else if buttons.firstIndex(of: sender)! == 0{
                controller.shiftUp()
            }
        }
    }

}
