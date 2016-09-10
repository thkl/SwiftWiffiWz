//
//  MeasurementViewController.swift
//  WiffiWZ
//
//  Created by Thomas Kluge on 09.09.16.
//  Copyright © 2016 kSquare.de. All rights reserved.
//

import Foundation
import UIKit

public class MeasurementViewController: UITableViewController {

  var measurement : WiffiMeasurement?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset.top = 20
    
    let manager = WiffiManager()
    manager.fetchMeasurements { (error, rec_measurement) in
     
      if (error == nil) {
        self.measurement = rec_measurement;
        DispatchQueue.main.async(execute: { 
          self.tableView.reloadData()
        })
      }
    
    }
  }
  
  public override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.measurement != nil ? 11 : 0
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "measureCell", for: indexPath)
    
    let l_yes = NSLocalizedString("yes",comment: "yes");
    let l_no = NSLocalizedString("no",comment: "no");
    
    switch indexPath.row {
      
    case 0:
      cell.textLabel?.text = NSLocalizedString("CO2",comment: "CO2")
      cell.detailTextLabel?.text = "\(self.measurement!.sensor_co2.doubleValue.format(f: ".0")) %"
      break;

    case 1:
      cell.textLabel?.text = NSLocalizedString("Temperature",comment: "Temperature")
      cell.detailTextLabel?.text = "\(self.measurement!.sensor_temperature.doubleValue.format(f: ".2")) °C"
      break;

      
    case 2:
      cell.textLabel?.text = NSLocalizedString("Humidity",comment: "Humidity")
      cell.detailTextLabel?.text = "\(self.measurement!.sensor_humidity.doubleValue.format(f: ".2")) %"
      break;

      
    case 3:
      cell.textLabel?.text = NSLocalizedString("Noise", comment: "Noise")
      cell.detailTextLabel?.text = "\((self.measurement!.sensor_isNoise) ? l_yes:l_no)"
      break;

      
    case 4:
      cell.textLabel?.text = NSLocalizedString("Motion left",comment: "Motion Left")
      cell.detailTextLabel?.text = "\((self.measurement!.sensor_motion_left) ? l_yes:l_no)"
      break;

    case 5:
      cell.textLabel?.text = NSLocalizedString("Motion right",comment: "Motion right")
      cell.detailTextLabel?.text = "\((self.measurement!.sensor_motion_right) ? l_yes:l_no )"
      break;


    case 6:
      cell.textLabel?.text = NSLocalizedString("Airpressure",comment: "Airpressure")
      cell.detailTextLabel?.text = "\(self.measurement!.sensor_airpressure.doubleValue.format(f: ".2")) mbar"
      break;

    case 7:
      cell.textLabel?.text = NSLocalizedString("Airpressure trend",comment: "Airpressure trend")
      cell.detailTextLabel?.text = "\(self.measurement!.sensor_airpressuretrend)"
      break;

      
    case 8:
      cell.textLabel?.text = NSLocalizedString("Brightness",comment: "Brightness")
      cell.detailTextLabel?.text = "\((self.measurement!.sensor_light).doubleValue.format(f: ".2")) lux"
      break;

    case 9:
      cell.textLabel?.text = NSLocalizedString("Sun Elevation",comment: "Sun Elevation")
      cell.detailTextLabel?.text = "\(self.measurement!.sensor_elevation.doubleValue.format(f: ".2")) °"
      break;

    case 10:
      cell.textLabel?.text = NSLocalizedString("Sun Azimut",comment: "Sun Azimut")
      cell.detailTextLabel?.text = "\(self.measurement!.sensor_azimut.doubleValue.format(f: ".2")) °"
      break;

    default:
      cell.textLabel?.text = "---"
    }
    
    return cell
  }
}


extension Double {
  func format(f: String) -> String {
    return String(format: "%\(f)f", self)
  }
}
