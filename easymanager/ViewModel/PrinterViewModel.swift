//
//  PrinterViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 02/04/23.
//

import Foundation
import SwiftUI

enum ReceiptType: String, CaseIterable {
    case preconto = "Preconto"
    case scontrinoFiscale = "Scontrino Fiscale"
    case fattura = "Fattura"
}

class PrinterViewModel : NSObject, ObservableObject {
    
    @Published var receiptType: ReceiptType = .preconto
    @Published var errorConnection: String?
    
    private var xmlString: String = ""
        
    func sendXMLRequest(receipt: OrderStruct) {
        var ricevuta = receipt
        ricevuta.orderFood.removeAll { food in
            food.foodReversed == true
        }
        
        let urlString = "http://192.168.001.150/cgi-bin/fpmate.cgi"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        switch receiptType {
        case .preconto:
            xmlString = """
                testo xml del preconto
            """
        case .fattura:
            xmlString = """
                testo xml della fattura
            """
        case .scontrinoFiscale:
            xmlString = """
            <?xml version=\"1.0\" encoding=\"utf-8\" ?>
                <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
                <s:Body>
                <printerFiscalReceipt>
                <beginFiscalReceipt operator=\"10\" />
            """
            for food in receipt.orderFood {
                xmlString.append("""
                                    <printRecItem operator=\"10\" description=\"\(food.foodName)\" quantity=\"\(food.foodQuantity)\" unitPrice=\"\(food.foodPrice)\" department=\"1\"/>
                                    <printRecItemAdjustment operator="10" adjustmentType="5" description="Ciccio Pasticcio" amount="15" />
                                 """
                )
            }
            xmlString.append("""
                    <printRecTotal operator=\"10\" description=\"CONTANTE\" payment=\"\(receipt.orderTotalPrice)\" paymentType=\"2\" index=\"0\" justification=\"1\" />"
                <printRecMessage  operator=\"10\" messageType=\"3\" index=\"1\" font=\"4\" message=\"Arrivederci e Grazie\" />
                <endFiscalReceipt operator=\"10\" />
                </printerFiscalReceipt>
                </s:Body>
                </s:Envelope>
                """
            )
        }
        
        request.httpBody = xmlString.data(using: .utf8)
        request.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("text/xml", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorConnection = error.localizedDescription
                }
                return
            }
        }
        task.resume()
    }
}




/*
 @Published var printers: [String] = []
 @AppStorage("selectedPrinterIP") var selectedPrinterIP: String?
 
 var browser: NetServiceBrowser!
 private var services: [NetService] = []
     
 override init() {
     super.init()
     self.browser = NetServiceBrowser()
     self.browser.delegate = self
     self.browser.searchForServices(ofType: "_printer._tcp", inDomain: "")
 }
 
 extension PrinterViewModel: NetServiceBrowserDelegate {
     func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
         printers.append(service.name)
         service.delegate = self
         service.resolve(withTimeout: 5)
         services.append(service)
     }
     
     func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
         if let index = services.firstIndex(of: service) {
             services.remove(at: index)
             printers.remove(at: index)
         }
     }
     
     func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
         services.forEach { $0.stop() }
         selectedPrinterIP = nil
     }
 }

 extension PrinterViewModel: NetServiceDelegate {
     func netServiceDidResolveAddress(_ sender: NetService) {
         if let address = sender.addresses?.first {
             let host = String(describing: address)
             let components = host.components(separatedBy: ":")
             if components.count >= 2 {
                 let ip = components[0]
                 if ip == selectedPrinterIP {
                     sender.stop()
                     selectedPrinterIP = nil
                 }
             }
         }
     }
 }
 
 
 
 
 
 
 
 
 
 
 var xmlString = """
 <?xml version=\"1.0\" encoding=\"utf-8\" ?>
     <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
     <s:Body>
     <printerFiscalReceipt>
     <beginFiscalReceipt operator=\"10\" />
 """
 for food in receipt.food {
     xmlString.append("""
                         <printRecItem operator=\"10\" description=\"\(food.foodName)\" quantity=\"\(food.foodQuantity)\" unitPrice=\"\(food.foodPrice)\" department=\"1\" justification=\"1\" />
                      """
     )
 }
 xmlString.append("""
         <printRecTotal operator=\"10\" description=\"CONTANTE\" payment=\"\(receipt.totalPrice)\" paymentType=\"2\" index=\"0\" justification=\"1\" />"
     <printRecMessage  operator=\"10\" messageType=\"3\" index=\"1\" font=\"4\" message=\"Arrivederci e Grazie\" />
     <endFiscalReceipt operator=\"10\" />
     </printerFiscalReceipt>
     </s:Body>
     </s:Envelope>
     """
 )
 */
