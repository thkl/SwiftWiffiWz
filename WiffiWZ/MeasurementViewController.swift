//
//  MeasurementViewController.swift
//  WiffiWZ
//
//  Created by Thomas Kluge on 09.09.16.
//  Copyright © 2016 kSquare.de. All rights reserved.
//

import Foundation
import UIKit

public class MeasurementViewController: UIViewController {
  
  var measurement : WiffiMeasurement?
  let manager = WiffiManager()
  var refreshTimer : Timer?
  var ringProgressView : MKRingProgressView?
  
  @IBOutlet weak var lblCurTemperature: UILabel!
  @IBOutlet weak var lblCurHumidity: UILabel!
  @IBOutlet weak var lblCurBrightness: UILabel!
  
  @IBOutlet weak var vwCo2Gauge: UIView!
  @IBOutlet weak var lblCo2: UILabel!
  @IBOutlet weak var lblAirPressure: UILabel!
  @IBOutlet weak var lblAirPressureTrend: UILabel!
  @IBOutlet weak var imgLeftMotion: UIImageView!
  @IBOutlet weak var imgRightMotion: UIImageView!
  @IBOutlet weak var lblNoise: UILabel!
  
  
  override public var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.updateMeasurements()
    
    refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
      self.updateMeasurements()
    })
    
    
    let sz = CGSize(width: 100, height: 100)
    ringProgressView = MKRingProgressView(frame: CGRect(x:0 , y: 0 , width: sz.width, height: sz.height))
    ringProgressView!.startColor = UIColor.red
    ringProgressView!.endColor = UIColor.green
    ringProgressView!.ringWidth = 10
    ringProgressView!.progress = 0.0
    
    ringProgressView!.transform = CGAffineTransform(rotationAngle: CGFloat(2 * M_PI_2));
    
    vwCo2Gauge.addSubview(ringProgressView!)
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateMeasurements), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
  }
  
  func updateMeasurements() {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    manager.fetchMeasurements { (error, rec_measurement) in
      
      if (error == nil) {
        self.measurement = rec_measurement;
        DispatchQueue.main.async(execute: {
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
          self.updateUI()
        })
      } else {
        print("WiffiWZ Update Error %@" , error)
      }
      
    }
  }
  
  func updateUI() {
    lblCurTemperature.text = "\(self.measurement!.sensor_temperature.doubleValue.format(f: ".1")) °C"
    lblCurHumidity.text = "\(self.measurement!.sensor_humidity.doubleValue.format(f: ".1")) %"
    lblCurBrightness.text = "\((self.measurement!.sensor_light).doubleValue.format(f: ".2")) lux"
    
    
    CATransaction.begin()
    CATransaction.setAnimationDuration(1.0)
    ringProgressView!.progress = (self.measurement!.sensor_co2.doubleValue/100)
    lblCo2.text = "\(self.measurement!.sensor_co2.doubleValue.format(f: ".0")) %"
    CATransaction.commit()
    lblAirPressure.text = "\(self.measurement!.sensor_airpressure.doubleValue.format(f: ".2")) mbar"
    let trend = NSLocalizedString(self.measurement!.sensor_airpressuretrend,comment:"")
    lblAirPressureTrend.text = "\(trend)"
    
    let irdImage = UIImage(named: "infrared-motion-detector")

    imgLeftMotion.image = irdImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    imgRightMotion.image = irdImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    
    imgLeftMotion.tintColor = (self.measurement!.sensor_motion_left) ? UIColor.red : UIColor.white
    imgRightMotion.tintColor = (self.measurement!.sensor_motion_right) ? UIColor.red : UIColor.white
    
    
    let l_yes = NSLocalizedString("yes",comment: "yes");
    let l_no = NSLocalizedString("no",comment: "no");
    
    lblNoise.text = "\((self.measurement!.sensor_isNoise) ? l_yes:l_no)"

  }
}


extension Double {
  func format(f: String) -> String {
    return String(format: "%\(f)f", self)
  }
}



