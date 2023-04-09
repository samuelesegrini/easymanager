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
            <printerFiscalReport>
                <printXZReport operator=\"\(user.userNOperator)\" timeout=\"1000\" />
            </printerFiscalReport>
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
                <printerFiscalReport>
                <printXReport operator=\"\(user.userNOperator)\" />
                </printerFiscalReport>
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
                <printerNonFiscal>
                <beginNonFiscal operator=\"\(user.userNOperator)\"/>
            """
            
            var total : Double = 0
            
            for food in ricevuta.orderFood {
                var foodTotal = 0.0
                for variants in food.foodVariants {
                    if variants.variantChecked  ?? false{
                        total += variants.variantPrice
                        foodTotal += variants.variantPrice
                    }
                }
                total += food.foodPrice
                foodTotal += food.foodPrice
                
                total *= food.foodQuantity
                foodTotal *= food.foodQuantity
                
                let maxLenght = 46
                let row = "\(food.foodQuantity)x  \(food.foodName)  \(food.foodIva)%\(foodTotal)€"
                var output = ""
                
                let percentIndex = row.firstIndex(of: "%") ?? row.startIndex
                let distance = row.distance(from: row.startIndex, to: percentIndex)
                
                let leftSpacesCount = max(distance, 0)
                let rightSpacesCount = max(maxLenght - row.count - leftSpacesCount - 1, 0)

                let leftSpaces = String(repeating: " ", count: leftSpacesCount)
                let rightSpaces = String(repeating: " ", count: rightSpacesCount)
                
                output = "\(row.prefix(upTo: percentIndex))%\(leftSpaces)\(rightSpaces)\(row.suffix(from: row.index(after: percentIndex)))"
                
                print(output)
                xmlString.append("""
                                    <printNormal operator=\"\(user.userNOperator)\" data=\"\(output)\" />
                                 """
                )
            }
            let maxLenght = 46
            let string = total.formatted(.number)
            
            let row = "TOTALE\(string)€"
            
            let totaleIndex = row.range(of: "TOTALE") ?? row.startIndex..<row.startIndex
            let distance = totaleIndex.upperBound
            
            let leftSpacesCount = max(row.distance(from: row.startIndex, to: distance), 0)
            let rightSpacesCount = max(maxLenght - row.count - leftSpacesCount, 0)

            let leftSpaces = String(repeating: " ", count: leftSpacesCount)
            let rightSpaces = String(repeating: " ", count: rightSpacesCount)
            
            let totaleString = "\(row.prefix(upTo: distance))\(leftSpaces)\(rightSpaces)\(row.suffix(from: distance))"
            
            xmlString.append("""
                   <printNormal operator=\"\(user.userNOperator)\" font=\"1\" data=\"\" comment=\"Add blank line (whitespace)\" />
                   <printNormal operator=\"\(user.userNOperator)\" font=\"4\" data=\"\(totaleString)\"/>
                """
            )
            xmlString.append("""
                <endNonFiscal operator=\"\(user.userNOperator)\" />
                </printerNonFiscal>
                </s:Body>
                </s:Envelope>
                """
            )
            print(xmlString)
        case .scontrinoFiscale:
            xmlString = """
            <?xml version=\"1.0\" encoding=\"utf-8\" ?>
                <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
                <s:Body>
                <printerFiscalReceipt>
                <beginFiscalReceipt operator=\"\(user.userNOperator)\" />
            """
            for food in ricevuta.orderFood {
                var department = 1
                if food.foodIva == "22"{
                    department = 1
                }else if food.foodIva == "10"{
                    department = 2
                }else if food.foodIva == "4"{
                    department = 3
                }
                
                xmlString.append("""
                                    <printRecItem operator=\"\(user.userNOperator)\" description=\"\(food.foodName)\" quantity=\"\(food.foodQuantity)\" unitPrice=\"\(food.foodPrice)\" department=\"\(department)\"/>
                                 """
                )
            }
            for pay in pagamento{
                if pay.pagamentoTipo == 0 {
                    xmlString.append( """
                                    <printRecTotal operator=\"\(user.userNOperator)\" description=\"Contante\" payment=\"\(pay.pagamentoImporto)\" paymentType=\"\(pay.pagamentoTipo)\" index=\"\(0)\"/>
                                    """
                    )
                } else if pay.pagamentoTipo == 1{
                    xmlString.append( """
                                    <printRecTotal operator=\"\(user.userNOperator)\" description=\"Assegno\" payment=\"\(pay.pagamentoImporto)\" paymentType=\"\(pay.pagamentoTipo)\" index=\"\(0)\"/>
                                    """
                    )
                }else if pay.pagamentoTipo == 2 {
                    xmlString.append( """
                                    <printRecTotal operator=\"\(user.userNOperator)\" description=\"Pagamento Elettronico\" payment=\"\(pay.pagamentoImporto)\" paymentType=\"\(pay.pagamentoTipo)\" index=\"\(1)\"/>
                                    """
                    )
                }else if pay.pagamentoTipo == 3 {
                    xmlString.append( """
                                    <printRecTotal operator=\"\(user.userNOperator)\" description=\"Ticket\" payment=\"\(pay.pagamentoImporto)\" paymentType=\"\(pay.pagamentoTipo)\" index=\"\(1)\"/>
                                    """
                    )
                }
            }
            xmlString.append("""
                <endFiscalReceipt operator=\"\(user.userNOperator)\"/>
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
