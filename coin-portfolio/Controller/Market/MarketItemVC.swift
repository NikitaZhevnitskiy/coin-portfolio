//
//  MarketItemVC.swift
//  coin-portfolio
//
//  Created by Nikita on 29/11/2017.
//  Copyright © 2017 Nikita. All rights reserved.
//

import UIKit

class MarketItemVC: UIViewController, UITextFieldDelegate {
    
    // outlets
    @IBOutlet weak var cardViewMarket: UIView!
    @IBOutlet weak var hourLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var weekLbl: UILabel!
    @IBOutlet weak var valutaNameLbl: UILabel!
    @IBOutlet weak var valuteImg: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    
    // portfolio card
    @IBOutlet weak var portfolioView: UIView!
    @IBOutlet weak var portfolioAmountLbl: UILabel!
    @IBOutlet weak var portfolioMoneySpendLbl: UILabel!
    @IBOutlet weak var portfolioTrendLbl: UILabel!
    
    
    
    // popup
    @IBOutlet weak var popupImg: UIImageView!
    @IBOutlet var popUp: UIView!
    @IBOutlet weak var amountField: UITextField!
    
    // vars
    var previousVC = MarketVC()
    var selectedValuta : Valuta?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(selectedValuta)
        initCardData()
        initPortfolioData()
        initCardDesign(view: self.cardViewMarket)
        initCardDesign(view: self.portfolioView)
        initPopupDesign()
    }
    
    
    /*
     ******************************* card view START **********************************
     **/
    func initCardDesign(view: UIView){
        view.layer.cornerRadius = 3
        view.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.layer.shadowOffset = CGSize(width: 0, height: 1.75)
        view.layer.shadowRadius = 1.7
        view.layer.shadowOpacity = 0.45
    }
    func initCardData(){
        if let valuta = selectedValuta {
            valutaNameLbl.text=valuta.name
            hourLbl.text="\(valuta.percent_change_1h)%"
            dayLbl.text="\(valuta.percent_change_24h)%"
            weekLbl.text="\(valuta.percent_change_7d)%"
            valuteImg.image = ApiDataService.instance.getImage(id: valuta.id)
            priceLbl.text = valuta.price_nok.roundedValue
        }
    }
    /*
     ******************************* card view END **********************************
     **/
    
    /*
     ******************************* portfolio view START **********************************
     **/
    func initPortfolioData(){
        if let valuta = selectedValuta {
            
            if let item = CoreDataService.instance.getItemById(id: valuta.id) as! PortfolioItem? {
                portfolioAmountLbl.text = item.amount.roundedValue
                portfolioMoneySpendLbl.text = item.spend_money.roundedValue
                
                let sellPrice = item.amount * valuta.price_nok
                let trend = sellPrice - item.spend_money
               
                if sellPrice >= item.spend_money {
                    portfolioTrendLbl.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                    portfolioTrendLbl.text = "+\(trend.roundedValue)"
                } else {
                    portfolioTrendLbl.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                    portfolioTrendLbl.text = "\(trend.roundedValue)"
                }
                portfolioView.isHidden=false
            } else {
                portfolioView.isHidden=true
            }
            
        } else {
            portfolioView.isHidden=true
        }
    }
    
    /*
     ******************************* portfolio view END **********************************
     **/
    
    
    
    /*
     ******************************* navbar view START **********************************
     **/
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    /*
     ******************************* navbar view END **********************************
     **/
    
    
    
    /*
     ******************************* popup START **********************************
     * https://youtu.be/CXvOS6hYADc
     **/
    func initPopupDesign(){
        // text field setup
        amountField.delegate = self

        popupImg.image = valuteImg.image
        popUp.layer.cornerRadius = 3
        popUp.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        popUp.layer.shadowOffset = CGSize(width: 0, height: 1.75)
        popUp.layer.shadowRadius = 1.7
        popUp.layer.shadowOpacity = 0.45
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let charSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: charSet)
    }
    
    func animateIn() {
        self.view.addSubview(popUp)
        popUp.center = self.view.center
        popUp.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popUp.alpha = 0
        UIView.animate(withDuration: 0.4) {
            // animate effects
            self.popUp.alpha = 1
            self.popUp.transform = CGAffineTransform.identity
        }
    }
    func animateOut(){
        UIView.animate(withDuration: 0.4, animations: {
            self.popUp.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            
        }) { (success: Bool) in
            self.popUp.removeFromSuperview()
        }
    }
    
    // ******** popup ACTIONS *******
    @IBAction func showPopup(_ sender: Any) {
        animateIn()
    }
    
    @IBAction func closePopup(_ sender: Any) {
        animateOut()
        //TODO: logic add to portfolio
        self.addItemToPortfolio()
        initPortfolioData()
        
    }
    /*
     ******************************* popup END **********************************
     **/
    
    
    
    
    /*
     ******************************* add item feature START **********************************
     **/
    func addItemToPortfolio() {
        if let text = amountField.text {
            if let amount = Double(text){
                print(amount)
                let spend_money = amount * (selectedValuta?.price_nok)!
                CoreDataService.instance.addToPortfolio(valuta: selectedValuta!, amount: amount, spend: spend_money)
            }
        }
        
        amountField.text = ""
    }
    /*
     ******************************* add item feature END **********************************
     **/
    
    
    
    
    /*
     ******************************* update feature START **********************************
     **/
    @IBAction func updateCardData(_ sender: Any) {
        updateValutas()
        initPortfolioData()
    }
    func updateValutas(){
//        debugPrint("previous state:  \(selectedValuta)")
        
        ApiDataService.instance.getTenValutas { (success) in
            if success {
                guard let id = self.selectedValuta?.id else {return}
                // update current valuta
                self.selectedValuta = ApiDataService.instance.getValutaById(id: id)
                // refresh view
                self.initCardData()
                self.initPortfolioData()
//                debugPrint("new state:  \(self.selectedValuta)")
            }
        }
    }
    /*
     ******************************* update feature END **********************************
     **/
    
}
