//
//  ViewController.swift
//  Socket服务端
//
//  Created by Broccoli on 15/11/4.
//  Copyright © 2015年 Broccoli. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var server: GCDAsyncSocket!
    lazy var clients = [GCDAsyncSocket]()
    
    @IBOutlet weak var TFPort: NSTextField!
    @IBOutlet weak var TFMessage: NSTextField!
    
    
    @IBAction func startAction(sender: AnyObject) {
        do {
            try server.acceptOnPort(uint16(TFPort.intValue))
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    @IBAction func stopAciton(sender: AnyObject) {
        let str = TFMessage.stringValue
        for client in clients {
                client.writeData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       server = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("readDataFromClients"), userInfo: nil, repeats: true)
    }

    func readDataFromClients() {
        for client in clients {
            client.readDataWithTimeout(-1, tag: 0)
        }
    }
}

extension ViewController: GCDAsyncSocketDelegate {
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        debugPrint("新的客户端连接进来, 动态端口: \(newSocket.connectedPort) 动态 IP: \(newSocket.connectedHost)")
        clients.append(newSocket)
        let str = "你已经连接到服务器"
        newSocket.writeData(str.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: -1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
//        let str = String(data: data, encoding: NSUTF8StringEncoding)!
//        debugPrint("客户端发送消息过来: \(str)")
        for client in clients {
            if client != sock {
                client.writeData(data, withTimeout: -1, tag: 0)
            }
        }
    }
}
