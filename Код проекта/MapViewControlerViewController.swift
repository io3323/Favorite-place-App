
import UIKit
import MapKit
import CoreLocation

protocol MapViewControlerViewControllerDelegate{
    func getAddress(_ address:String?)
    
}
class MapViewControlerViewController: UIViewController {
    
    
    var place = Place()
    var mapViewControllerDelegate:MapViewControlerViewControllerDelegate?
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.0
    var incomeSegueIdentifire = ""
    var placeCoordinate:CLLocationCoordinate2D?
    
    @IBOutlet var mapPinImage:UIImageView!
    @IBOutlet var mapView:MKMapView!
    @IBOutlet var addressLabel:UILabel!
    @IBOutlet var doneButton:UIButton!
    @IBOutlet var goButton:UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    @IBAction func senterViewInUserLocation(){
        showUserLocation()
    }
    @IBAction func doneButtonPress(){
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    @IBAction func goButtonPressed(){
        getDirections()
        
    }
    @IBAction func closeVC(){
        dismiss(animated: true)
    }
    
    private func setupMapView(){
        
        goButton.isHidden = true
        if incomeSegueIdentifire == "showPlace"{
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    private func setupPlacemark(){
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) {(placemarks, error) in
            if let error =  error{
                print(error)
                return
            }
            guard  let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            
            let annotation =  MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated:true)
            
            
        }
    }
    private func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 ){
                
                self.showAlert(title: "Location Services are Disable", message: "To enable it go")
            }
        }
    }
    
    private func setupLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    private func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifire == "getAddress" {showUserLocation()}
            break
        case .denied:
            break
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
    private func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func getDirections(){
        guard  let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Curent location is not found")
            return
        }
        guard  let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error{
                print(error)
                return
            }
            guard let response = response  else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
                
            }
            for route in response.routes{
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval  = route.expectedTravelTime
                
                print("Rastonie do mesta: \(distance) km.")
                print("vrema v puti : \(timeInterval) sek.")
                
            }
        }
    }
    private func createDirectionsRequest(from coordinate:CLLocationCoordinate2D) -> MKDirections.Request?{
        guard let destenationCoordinate = placeCoordinate else {return nil}
        let startingLocations = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destenationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocations)
        
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    private func getCenterLocation(for mapView:MKMapView) -> CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    private func showUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
}

extension MapViewControlerViewController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotation == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds  = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                }else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                }else{
                    self.addressLabel.text = ""
                }
                
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        
        return  render
    }
}
extension MapViewControlerViewController:CLLocationManagerDelegate{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
