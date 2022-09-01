//
//  ViewController.swift
//  WebSocketSwift
//
//  Created by Zhora Babakhanyan on 8/31/22.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket: URLSessionWebSocketTask?
    @IBOutlet weak var responseLabel: UILabel!
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
        
    }
    
    // MARK: - Networking
    func ping(){
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping Error: \(error)")
            }
        })
    }
    func close(){
        webSocket?.cancel(with: .goingAway, reason: "Demo Ended".data(using: .utf8))
    }
    func send(){
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.send()
            self.webSocket?.send(.string("Send new message: \(Int.random(in: 0...1000))"), completionHandler: { error in
                if let error = error {
                    print("Send error: \(error)")
                }
            })
        }
    }
    func receive(){
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got Data \(data)")
                case .string(let message):
                    print("Got String: \(message)")
                    self?.updateUI(str: message)
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }
            self?.receive()
        })
    }
    
    
    func updateUI(str: String) {
        DispatchQueue.main.async {
            self.responseLabel.text = str

        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did Connect to Socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did Close conection with reason")
    }
}

