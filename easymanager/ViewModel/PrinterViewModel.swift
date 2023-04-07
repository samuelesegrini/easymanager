//
//  PrinterViewModel.swift
//  easymanager
//
//  Created by Samuele Segrini on 03/04/23.
//

import Foundation
import SwiftUI

enum ReceiptType: String, CaseIterable {
    case preconto = "Preconto"
    case scontrinoFiscale = "Scontrino Fiscale"
}

class PrinterViewModel : NSObject, ObservableObject {
    
    @Published var receiptType: ReceiptType = .scontrinoFiscale
    @Published var errorConnection: String?
    
    private var xmlString: String = ""
        
    func printXZReport(user : UserStruct) {
        let urlString = "http://192.168.001.150/cgi-bin/fpmate.cgi"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        xmlString = """
        <?xml version=\"1.0\" encoding=\"utf-8\" ?>
            <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
            <s:Body>
        """
        
        xmlString.append( """
                <printXZReport operator=\"\(user.userNOperator)\" timeout=\"1000\" />
            """
        )
        xmlString.append("""
            </s:Body>
            </s:Envelope>
            """
        )
        
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
    func printXReport(user : UserStruct) {
        let urlString = "http://192.168.001.150/cgi-bin/fpmate.cgi"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        xmlString = """
        <?xml version=\"1.0\" encoding=\"utf-8\" ?>
            <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
            <s:Body>
        """
        
        xmlString.append( """
                <printXReport operator=\"\(user.userNOperator)\" />
            """
        )
        xmlString.append("""
            </s:Body>
            </s:Envelope>
            """
        )
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
    func printInvoiceLastReceipt(user : UserStruct) {
        let urlString = "http://192.168.001.150/cgi-bin/fpmate.cgi"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        xmlString = """
        <?xml version=\"1.0\" encoding=\"utf-16\" ?>
            <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
            <s:Body>
            <printerFiscalDocument>
        """
        xmlString.append( """
                    <printFiscalDocument operator=\"\(user.userNOperator)\" document=\"Invoice\" number=\"0\" />
            """
        )
        xmlString.append( """
                        </printerFiscalDocument>
                         </s:Body>
                         </s:Envelope>
                    """
        )
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
    func sendXMLRequest(receipt: OrderStruct, subtotale : Double, pagamento : [pagamento], user : UserStruct) {
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
            <?xml version=\"1.0\" encoding=\"utf-8\" ?>
                <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
                <s:Body>
                <printerNonFiscalReceipt>
                <beginNonFiscal operator=\"\(user.userNOperator)\" />

            """
            for food in receipt.orderFood {
                xmlString.append("""
                                    <printNormal operator="\(user.userNOperator)" data="\(food.foodQuantity)X \(food.foodName)      \(food.foodIva)% " />
                                    <printNormal operator=\"\(user.userNOperator)\" font=\"1\" data=\"\" comment=\"Add blank line (whitespace)\" />
                                 """
                )
            }
            xmlString.append("""
                <endNonFiscal operator=\"\(user.userNOperator)\" />
                </printerFiscalReceipt>
                </s:Body>
                </s:Envelope>
                """
            )
        case .scontrinoFiscale:
            xmlString = """
            <?xml version=\"1.0\" encoding=\"utf-8\" ?>
                <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
                <s:Body>
                <printerFiscalReceipt>
                <beginFiscalReceipt operator=\"\(user.userNOperator)\" />
            """
            for food in receipt.orderFood {
                var department = 1
                if food.foodIva == "22"{
                    department = 1
                }else if food.foodIva == "10"{
                    department = 2
                }else if food.foodIva == "4"{
                    department = 3
                    
                    xmlString.append("""
                                    <printRecItem operator=\"\(user.userNOperator)\" description=\"\(food.foodName)\" quantity=\"\(food.foodQuantity)\" unitPrice=\"\(food.foodPrice)\" department=\"\(department)\"/>
                                 """
                    )
                }
            }
            for pay in pagamento{
                xmlString.append( """
                                <printRecTotal operator=\"\(user.userNOperator)\" description=\"DA PAGARE\" payment=\"\(pay.pagamentoImporto)\" paymentType=\"\(pay.pagamentoTipo)\" index=\"\(pay.pagamentoTipo == 0 ? 0 : pay.pagamentoTipo == 1 ? 0 : pay.pagamentoTipo == 2 ? 1 : pay.pagamentoTipo == 3 ? 1 : 0)\" />"
                                """
                )
            }
            xmlString.append("""
                <endFiscalReceipt operator=\"\(user.userNOperator)\" />
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
