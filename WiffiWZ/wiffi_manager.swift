//
//  wiffi_manager.swift
//  WiffiWZ
//
//  Created by Thomas Kluge on 09.09.16.
//  Copyright © 2016 kSquare.de. All rights reserved.
//

import Foundation

public class WiffiMeasurement : NSObject {
  
  public var sensor_ip : String = "invalid"
  public var sensor_co2: NSNumber = 0.0
  public var sensor_temperature: NSNumber = 0.0
  public var sensor_humidity: NSNumber = 0.0
  public var sensor_isNoise: Bool = false
  public var sensor_airpressure : NSNumber = 0.0
  public var sensor_airpressuretrend : String = ""
  public var sensor_motion_left : Bool = false
  public var sensor_motion_right : Bool = false
  public var sensor_light : NSNumber = 0.0
  public var sensor_elevation : NSNumber = 0.0
  public var sensor_azimut : NSNumber = 0.0
  
  private func fetchValue(variables : NSArray , key : String )->AnyObject? {
    let predicate = NSPredicate(format: "SELF['name'] == '\(key)'")
    let element = variables.filtered(using: predicate)
    if let first = element.first as! NSDictionary! {
      return first.object(forKey: "value") as AnyObject?
    }
    return nil
  }
  
  
  init(jsonObject : NSDictionary?) {
    super.init()
    if let variables = jsonObject?["vars"] as? NSArray {
      
      if let tmp = self.fetchValue(variables: variables, key: "0") as? String {
        self.sensor_ip = tmp
      }

      if let tmp = self.fetchValue(variables: variables, key: "1") as? NSNumber {
        self.sensor_co2 = tmp
      }
      
      if let tmp = self.fetchValue(variables: variables, key: "2") as? NSNumber {
        self.sensor_temperature = tmp
      }
      
      if let tmp = self.fetchValue(variables: variables, key: "3") as? NSNumber {
        self.sensor_humidity = tmp
      }
      
      if let tmp = self.fetchValue(variables: variables, key: "4") as? NSNumber {
        self.sensor_isNoise = tmp.boolValue
      }
      
      if let tmp =  self.fetchValue(variables: variables, key: "5") as? String {
        self.sensor_airpressuretrend = tmp
      }
      
      if let tmp =  self.fetchValue(variables: variables, key: "6") as? NSNumber{
        self.sensor_motion_left = tmp.boolValue
      }
      
      if let tmp =  self.fetchValue(variables: variables, key: "7") as? NSNumber {
        self.sensor_motion_right = tmp.boolValue
      }
      
      if let tmp = self.fetchValue(variables: variables, key: "8") as? NSNumber {
        self.sensor_light = tmp
      }
      
      if let tmp =  self.fetchValue(variables: variables, key: "9") as? NSNumber {
        self.sensor_airpressure = tmp
      }
      
      if let tmp = self.fetchValue(variables: variables, key: "10") as? NSNumber{
        self.sensor_elevation = tmp
      }
      
      if let tmp = self.fetchValue(variables: variables, key: "11") as? NSNumber{
        self.sensor_azimut = tmp
      }
      
    }
  }
  
}

class WiffiManager: NSObject, URLSessionDelegate {
  
  var session : URLSession!
  var hostname : String = "wiffi_wz.local"
  override init() {
    
  super.init()
    let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default;
    sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
  }
  
  func wiffi_networkRequest(parameters : Array<String>,completion: @escaping (_ result: Data? , _ error : Error?)-> Void ) {
    
    let argument = parameters.joined(separator: ":")
    let request = NSMutableURLRequest(url: URL(string: "http://\(hostname)/?\(argument):")!)
    request.httpMethod = "GET"
    request.timeoutInterval = 5
    let task :  URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      
        completion(data,error)
    })
    
    task.resume()
  }
  
  public func setupWifi(ssid: String, passwd:String,completion:@escaping (_ error : Error?)->Void) {
  
    // Switch to AtHoc Adress
    
    self.hostname = "192.168.4.1"
    var callerror : Error? = nil
    
    var semaphore = DispatchSemaphore(value: 0)

    self.wiffi_networkRequest(parameters: ["ssid","\(ssid)"],completion: { (data, error) in
      if (error != nil) {
        callerror = error!
      }
      semaphore.signal()
    })
  
    var dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

    let _ = semaphore.wait(timeout: dispatchTime)
    semaphore = DispatchSemaphore(value: 0)
    
    self.wiffi_networkRequest(parameters: ["pwd","\(passwd)"],completion: { (data, error) in
      if (error != nil) {
        callerror = error!
      }
      semaphore.signal()
    })
    
    semaphore = DispatchSemaphore(value: 0)
    
    self.wiffi_networkRequest(parameters: ["reset"],completion: { (data, error) in
      if (error != nil) {
        callerror = error!
      }
      semaphore.signal()
    })
    
    
    dispatchTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    let _ = semaphore.wait(timeout: dispatchTime)
    
    //switch back
    self.hostname = "wiffi_wz.local"
    completion(callerror)
    
  }

  
  public func calibrateAirPressureSensor(heightoverground:Int ,completion:@escaping (_ error : Error?)->Void) {
    self.wiffi_networkRequest(parameters: ["param","13","\(heightoverground)"],completion: { (data, error) in
      completion(error)
    })
  }
  
  public func calibrateCO2Sensor(completion:@escaping (_ error : Error?)->Void) {
    
    self.wiffi_networkRequest(parameters: ["calibrate"],completion: { (data, error) in
      completion(error)
    })
  }
  
  
  public func fetchMeasurements(completion:@escaping (_ error : Error? ,_ data : WiffiMeasurement? )->Void ) {
    
    // first make a call and fetch the json
    self.wiffi_networkRequest(parameters: ["json"],completion: { (data, error) in
      if (error == nil) {
        
        // quick and dirty fix the JSON BUG if nan value
        let strResult :NSString = NSString(data: data!, encoding: String.Encoding.ascii.rawValue)!
        let fixedResult = strResult.replacingOccurrences(of : "\"value\":nan}", with: "\"value\":-99999999}")
        
        do {
          let jsonDict = try JSONSerialization.jsonObject(with: fixedResult.data(using: .utf8)!, options: .allowFragments) as? NSDictionary
          if (jsonDict != nil) {
            // Parse
            let measurement = WiffiMeasurement(jsonObject: jsonDict!)
            completion(error,measurement);
          } else {
            completion(error,nil);
          }
        } catch {
          completion(error,nil);
        }
      } else {
        completion(error,nil);
      }
    })
  }




  
}
