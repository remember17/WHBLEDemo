//
//  ViewController.swift
//  蓝牙外设Swift
//
//  Created by 吴浩 on 2018/1/12.
//  Copyright © 2018年 wuhao. All rights reserved.
//

import UIKit
import CoreBluetooth

private let Service_UUID: String = "CDD1"
private let Characteristic_UUID: String = "CDD2"

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    private var peripheralManager: CBPeripheralManager?
    private var characteristic: CBMutableCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "蓝牙外设"
        peripheralManager = CBPeripheralManager.init(delegate: self, queue: .main)
    }
    
    @IBAction func didClickPost(_ sender: Any) {
        peripheralManager?.updateValue((textField.text ?? "empty data!").data(using: .utf8)!, for: characteristic!, onSubscribedCentrals: nil)
    }
}


extension ViewController: CBPeripheralManagerDelegate {
    
    // 蓝牙状态
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("未知的")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支持")
        case .unauthorized:
            print("未验证")
        case .poweredOff:
            print("未启动")
        case .poweredOn:
            print("可用")
            // 创建Service（服务）和Characteristics（特征）
            setupServiceAndCharacteristics()
            // 根据服务的UUID开始广播
            self.peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [CBUUID.init(string: Service_UUID)]])
        }
    }
    
    /** 创建服务和特征 */
    private func setupServiceAndCharacteristics() {
        let serviceID = CBUUID.init(string: Service_UUID)
        let service = CBMutableService.init(type: serviceID, primary: true)
        let characteristicID = CBUUID.init(string: Characteristic_UUID)
        let characteristic = CBMutableCharacteristic.init(type: characteristicID,
                                                          properties: [.read, .write, .notify],
                                                          value: nil,
                                                          permissions: [.readable, .writeable])
        service.characteristics = [characteristic]
        self.peripheralManager?.add(service)
        self.characteristic = characteristic
    }
    
    /** 中心设备读取数据的时候回调 */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        // 请求中的数据，这里把文本框中的数据发给中心设备
        request.value = self.textField.text?.data(using: .utf8)
        // 成功响应请求
        peripheral.respond(to: request, withResult: .success)
    }
    
    /** 中心设备写入数据 */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        let request = requests.last!
        self.textField.text = String.init(data: request.value!, encoding: String.Encoding.utf8)
    }
    
    /** 订阅成功回调 */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("\(#function) 订阅成功回调")
    }
    
    /** 取消订阅回调 */
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("\(#function) 取消订阅回调")
    }
    
}
