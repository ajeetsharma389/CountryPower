//
//  ViewController.swift
//  Assigment_S
//
//  Created by Ajeet on 01/12/19.
//  Copyright © 2019 CG. All rights reserved.
//

import UIKit
import MapKit
class LandingPageController: UIViewController {
    
    var utilHelper =  Utils()
    
    // Data source for Region data
    var regionDataDataSource = [RegionMetaData]()
    
    // Data source for item data
    var itemsDataSource = [Items]()
    
    // Network Manager
    let networkManager = NetworkManager(apiHandler: APIHandler.sharedInstance)
    
    @IBOutlet weak var filterSegmentControl: UISegmentedControl?
    
    // MAP View
    @IBOutlet weak var psiMapView: MKMapView!
    
    // regionData variable
    var  regionData: [PollutionAnnotation] = []
    
    // Location Manager
    let locationManager = CLLocationManager()
    
    // Array to store readings array from Response
    var readingStringArray:[String] = [String]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        /// Initially keep map on center
        centerLocationOnMap()
        
        // Register CalloutView for showing on click of annotaion pin
        psiMapView.register(CallOutView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        /// Showing loader when calling API
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.createLoaderView()
        
        // Initial call of API for atTheMoment parameter
        loadPSIListForDateNTime(atTheMoment)
        
    }
    
    ///////  Create the data recieved from API to populate the MAP
    func loadInitialData() {
        
        // Intentionally taking only one index from array. Data count handling should be taken here before proceed
        
        if self.itemsDataSource.count > 0 {
            let itemsList  = self.itemsDataSource[0] as Items
            let readingsList = itemsList.readings
            
            
            /// Creating Pollution index String data for each zone in sequence
            let resultStringWest = createMutableStringWestZone(readingsList: readingsList!)
            readingStringArray.append(resultStringWest)
            
            let resultStringNational = createMutableStringNationalZone(readingsList: readingsList!)
            //print(resultStringNational)
            readingStringArray.append(resultStringNational)
            
            let resultStringEast = createMutableStringEastZone(readingsList: readingsList!)
            readingStringArray.append(resultStringEast)
            
            let resultStringCentral = createMutableStringCentralZone(readingsList: readingsList!)
            readingStringArray.append(resultStringCentral)
            
            
            let resultStringSouth = createMutableStringSouthZone(readingsList: readingsList!)
            readingStringArray.append(resultStringSouth)
            
            let resultStringNorth = createMutableStringNorthZone(readingsList: readingsList!)
            readingStringArray.append(resultStringNorth)
            
            generateAnnotationForAllZone()
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    
    
    // MARK: - Button action Method for at the moment call
    @IBAction func getRemoteData(sender: UISegmentedControl) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.createLoaderView()
        switch sender.selectedSegmentIndex {
        case 0:
            loadPSIListForDateNTime(atTheMoment)
        case 1:
            loadPSIListForDateNTime(dayWise)
        default:
            loadPSIListForDateNTime(atTheMoment)
        }
    }
    
    
    // MARK: - API call to get PSI list on
    func loadPSIListForDateNTime(_ inputParameter : String) {
        
        var params: String = ""
        if inputParameter == atTheMoment {
            let currentDateTime = utilHelper.getCurrentDateTime()
            params = "date_time=\(currentDateTime)"
        }
        if inputParameter == dayWise {
            let currentDate = utilHelper.getCurrentDate()
            params = "date=\(currentDate)"
        }
        
        networkManager.getPSIListForDateNTime(urlString: baseUrl+params) { (result) in
            
            switch result {
            case .success(let returnData):
                DispatchQueue.main.async {
                    self.regionDataDataSource = returnData.region_metadata!
                    self.itemsDataSource = returnData.items!
                    self.loadInitialData()
                    // Remove the loader view
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.removeLoaderView()
                }
                
            case .failure( _):
                // Remove the loader view
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.removeLoaderView()
                }
            }
        }
    }
}


extension LandingPageController {
    
    // MARK: - CLLocationManager
    
    // To center the Map view respect to Device screen
    func centerLocationOnMap() {
        
        // setting a center position of all lat and long for region on Map
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: defaultLat,
                                                                       longitude: defaultLong), span: MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45))
        self.psiMapView.setRegion(region, animated: true)
        psiMapView.setRegion(region, animated: true)
    }
    
    ///  Show the authorization message to user
    func checkLocationAuthorizationStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            psiMapView.showsUserLocation = true
        } else {
            locationManager.requestAlwaysAuthorization()
        }
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            psiMapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    //MARK: - Helper Method
    
    // Generate Annotation pin drop for all Zone coming from Response
    func generateAnnotationForAllZone() {
        
        let dataCount = self.regionDataDataSource.count
        
        // To avoid zero value before iterating the loop
        // Always calculate the array length before puting into loop, it improves performance
        if dataCount > 0 {
            /// Remove all previous annotaions to refresh the new data
            psiMapView.removeAnnotations(psiMapView.annotations)
            for eachValue in 0..<dataCount {
                
                let lat :Double = (self.regionDataDataSource[eachValue].label_location?.latitude)!
                let long :Double = (self.regionDataDataSource[eachValue].label_location?.longitude)!
                let initialLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                if lat != 0.0 && long != 0.0 {
                    
                    /// Initializing data for PollutionAnnotation
                    let zoneName = "Readings: \(self.regionDataDataSource[eachValue].name?.capitalized ?? "zone")"
                    let point = PollutionAnnotation(title: zoneName,pollutionIndexString: readingStringArray[eachValue],
                                                    coordinate: initialLocation)
                    
                    psiMapView.addAnnotation(point)
                }
            }
        }
        else {
            print("Error! Data not found")
        }
        // To center the Map to make visible on the Screen
        centerLocationOnMap()
    }
    
    /// Creating mutable string to show on callout view on tap of annotation ZoneWise
    func createMutableStringWestZone(readingsList: Readings) -> String {
        
        let showingIndexStringForWest: NSMutableString = ""
        
        showingIndexStringForWest.appendFormat("\(o3_sub_index): %i\n" as NSString,
                                               (readingsList.co_sub_index?.west)!)
        
        showingIndexStringForWest.appendFormat("\(pm10_twenty_four_hourly): %i\n" as NSString,
                                               (readingsList.pm10_twenty_four_hourly?.west)!)
        
        showingIndexStringForWest.appendFormat("\(pm10_sub_index): %i\n" as NSString,
                                               (readingsList.pm10_sub_index?.west)!)
        
        showingIndexStringForWest.appendFormat("\(co_sub_index): %i\n" as NSString,
                                               (readingsList.co_sub_index?.west)!)
        
        showingIndexStringForWest.appendFormat("\(pm25_twenty_four_hourly): %i\n" as NSString,
                                               (readingsList.pm25_twenty_four_hourly?.west)!)
        
        showingIndexStringForWest.appendFormat("\(so2_sub_index): %i\n" as NSString,
                                               (readingsList.so2_sub_index?.west)!)
        
        showingIndexStringForWest.appendFormat("\(co_eight_hour_max): %i\n" as NSString,
                                               (readingsList.co_eight_hour_max?.west)!)
        
        showingIndexStringForWest.appendFormat("\(no2_one_hour_max): %i\n" as NSString,
                                               (readingsList.no2_one_hour_max?.west)!)
        
        showingIndexStringForWest.appendFormat("\(so2_twenty_four_hourly): %i\n" as NSString,
                                               (readingsList.so2_twenty_four_hourly?.west)!)
        
        showingIndexStringForWest.appendFormat("\(pm25_sub_index): %i\n" as NSString,
                                               (readingsList.pm25_sub_index?.west)!)
        
        showingIndexStringForWest.appendFormat("\(psi_twenty_four_hourly): %i\n" as NSString,
                                               (readingsList.psi_twenty_four_hourly?.west)!)
        
        showingIndexStringForWest.appendFormat("\(o3_eight_hour_max): %i\n" as NSString,
                                               (readingsList.o3_eight_hour_max?.west)!)
        
        
        return showingIndexStringForWest as String
    }
    
    func createMutableStringEastZone(readingsList: Readings) -> String {
        
        let showingIndexStringForEast: NSMutableString = ""
        
        showingIndexStringForEast.appendFormat("\(o3_sub_index): %i\n" as NSString,
                                                (readingsList.co_sub_index?.east)!)
        
        showingIndexStringForEast.appendFormat("\(pm10_twenty_four_hourly): %i\n" as NSString,
                                               (readingsList.pm10_twenty_four_hourly?.east)!)
        
        showingIndexStringForEast.appendFormat("\(pm10_sub_index): %i\n" as NSString,
                                                (readingsList.pm10_sub_index?.east)!)
        
        showingIndexStringForEast.appendFormat("\(co_sub_index): %i\n" as NSString,
                                                (readingsList.co_sub_index?.east)!)
        
        showingIndexStringForEast.appendFormat("\(pm25_twenty_four_hourly): %i\n" as NSString,
                                               (readingsList.pm25_twenty_four_hourly?.east)!)
        
        showingIndexStringForEast.appendFormat("\(so2_sub_index): %i\n" as NSString,
                                                (readingsList.so2_sub_index?.east)!)
        
        showingIndexStringForEast.appendFormat("\(co_eight_hour_max): %i\n" as NSString,
                                                (readingsList.co_eight_hour_max?.east)!)
        
        showingIndexStringForEast.appendFormat("\(no2_one_hour_max): %i\n" as NSString,
                                                (readingsList.no2_one_hour_max?.east)!)
        
        showingIndexStringForEast.appendFormat("\(so2_twenty_four_hourly): %i\n" as NSString,
                                               (readingsList.so2_twenty_four_hourly?.east)!)
        
        showingIndexStringForEast.appendFormat("\(pm25_sub_index): %i\n" as NSString,
                                                (readingsList.pm25_sub_index?.east)!)
        
        showingIndexStringForEast.appendFormat("\(psi_twenty_four_hourly): %i\n" as NSString,
                                               (readingsList.psi_twenty_four_hourly?.east)!)
        
        showingIndexStringForEast.appendFormat("\(o3_eight_hour_max): %i\n" as NSString,
                                                (readingsList.o3_eight_hour_max?.east)!)
        

        return showingIndexStringForEast as String
    }
    
    func createMutableStringNorthZone(readingsList:Readings) -> String {
        
        let showingIndexStringForNorth: NSMutableString = ""
        
        showingIndexStringForNorth.appendFormat("\(o3_sub_index): %i\n" as NSString,
                                                (readingsList.co_sub_index?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(pm10_twenty_four_hourly): %i\n" as NSString,
                                                (readingsList.pm10_twenty_four_hourly?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(pm10_sub_index): %i\n" as NSString,
                                                (readingsList.pm10_sub_index?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(co_sub_index): %i\n" as NSString,
                                                (readingsList.co_sub_index?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(pm25_twenty_four_hourly): %i\n" as NSString,
                                                (readingsList.pm25_twenty_four_hourly?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(so2_sub_index): %i\n" as NSString,
                                                (readingsList.so2_sub_index?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(co_eight_hour_max): %i\n" as NSString,
                                                (readingsList.co_eight_hour_max?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(no2_one_hour_max): %i\n" as NSString,
                                                (readingsList.no2_one_hour_max?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(so2_twenty_four_hourly): %i\n" as NSString,
                                                (readingsList.so2_twenty_four_hourly?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(pm25_sub_index): %i\n" as NSString,
                                                (readingsList.pm25_sub_index?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(psi_twenty_four_hourly): %i\n" as NSString,
                                                (readingsList.psi_twenty_four_hourly?.north)!)
        
        showingIndexStringForNorth.appendFormat("\(o3_eight_hour_max): %i\n" as NSString,
                                                (readingsList.o3_eight_hour_max?.north)!)
        

        return showingIndexStringForNorth as String
    }
    
    func createMutableStringSouthZone(readingsList:Readings) -> String {
        
        let showingIndexStringForSouth: NSMutableString = ""
        
        showingIndexStringForSouth.appendFormat("\(o3_sub_index): %i\n" as NSString,
                                                  (readingsList.co_sub_index?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(pm10_twenty_four_hourly): %i\n" as NSString,
                                                (readingsList.pm10_twenty_four_hourly?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(pm10_sub_index): %i\n" as NSString,
                                                  (readingsList.pm10_sub_index?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(co_sub_index): %i\n" as NSString,
                                                  (readingsList.co_sub_index?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(pm25_twenty_four_hourly): %i\n" as NSString,
                                                (readingsList.pm25_twenty_four_hourly?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(so2_sub_index): %i\n" as NSString,
                                                  (readingsList.so2_sub_index?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(co_eight_hour_max): %i\n" as NSString,
                                                  (readingsList.co_eight_hour_max?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(no2_one_hour_max): %i\n" as NSString,
                                                  (readingsList.no2_one_hour_max?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(so2_twenty_four_hourly): %i\n" as NSString,
                                                (readingsList.so2_twenty_four_hourly?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(pm25_sub_index): %i\n" as NSString,
                                                  (readingsList.pm25_sub_index?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(psi_twenty_four_hourly): %i\n" as NSString,
                                                (readingsList.psi_twenty_four_hourly?.south)!)
        
        showingIndexStringForSouth.appendFormat("\(o3_eight_hour_max): %i\n" as NSString,
                                                  (readingsList.o3_eight_hour_max?.south)!)

        
        return showingIndexStringForSouth as String
    }
    
    func createMutableStringCentralZone(readingsList:Readings) -> String {
        
        let showingIndexStringForCentral: NSMutableString = ""
        
        showingIndexStringForCentral.appendFormat("\(o3_sub_index): %i\n" as NSString,
                                                  (readingsList.co_sub_index?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(pm10_twenty_four_hourly): %i\n" as NSString,
                                                  (readingsList.pm10_twenty_four_hourly?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(pm10_sub_index): %i\n" as NSString,
                                                  (readingsList.pm10_sub_index?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(co_sub_index): %i\n" as NSString,
                                                  (readingsList.co_sub_index?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(pm25_twenty_four_hourly): %i\n" as NSString,
                                                  (readingsList.pm25_twenty_four_hourly?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(so2_sub_index): %i\n" as NSString,
                                                  (readingsList.so2_sub_index?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(co_eight_hour_max): %i\n" as NSString,
                                                  (readingsList.co_eight_hour_max?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(no2_one_hour_max): %i\n" as NSString,
                                                  (readingsList.no2_one_hour_max?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(so2_twenty_four_hourly): %i\n" as NSString,
                                                  (readingsList.so2_twenty_four_hourly?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(pm25_sub_index): %i\n" as NSString,
                                                  (readingsList.pm25_sub_index?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(psi_twenty_four_hourly): %i\n" as NSString,
                                                  (readingsList.psi_twenty_four_hourly?.central)!)
        
        showingIndexStringForCentral.appendFormat("\(o3_eight_hour_max): %i\n" as NSString,
                                                  (readingsList.o3_eight_hour_max?.central)!)
        
        return showingIndexStringForCentral as String
    }
    
    func createMutableStringNationalZone(readingsList:Readings) -> String {
        
        let showingIndexStringForNational: NSMutableString = ""
        
        showingIndexStringForNational.appendFormat("\(o3_sub_index): %i\n" as NSString,
                                                  (readingsList.co_sub_index?.national)!)
        
        showingIndexStringForNational.appendFormat("\(pm10_twenty_four_hourly): %i\n" as NSString,
                                                   (readingsList.pm10_twenty_four_hourly?.national)!)
        
        showingIndexStringForNational.appendFormat("\(pm10_sub_index): %i\n" as NSString,
                                                  (readingsList.pm10_sub_index?.national)!)
        
        showingIndexStringForNational.appendFormat("\(co_sub_index): %i\n" as NSString,
                                                  (readingsList.co_sub_index?.national)!)
        
        showingIndexStringForNational.appendFormat("\(pm25_twenty_four_hourly): %i\n" as NSString,
                                                   (readingsList.pm25_twenty_four_hourly?.national)!)
        
        showingIndexStringForNational.appendFormat("\(so2_sub_index): %i\n" as NSString,
                                                  (readingsList.so2_sub_index?.national)!)
        
        showingIndexStringForNational.appendFormat("\(co_eight_hour_max): %i\n" as NSString,
                                                  (readingsList.co_eight_hour_max?.national)!)
        
        showingIndexStringForNational.appendFormat("\(no2_one_hour_max): %i\n" as NSString,
                                                  (readingsList.no2_one_hour_max?.national)!)
        
        showingIndexStringForNational.appendFormat("\(so2_twenty_four_hourly): %i\n" as NSString,
                                                   (readingsList.so2_twenty_four_hourly?.national)!)
        //
        showingIndexStringForNational.appendFormat("\(pm25_sub_index): %i\n" as NSString,
                                                  (readingsList.pm25_sub_index?.national)!)
        
        showingIndexStringForNational.appendFormat("\(psi_twenty_four_hourly): %i\n" as NSString,
                                                   (readingsList.psi_twenty_four_hourly?.national)!)
        
        showingIndexStringForNational.appendFormat("\(o3_eight_hour_max): %i\n" as NSString,
                                                  (readingsList.o3_eight_hour_max?.national)!)
        
        return showingIndexStringForNational as String
    }
}
