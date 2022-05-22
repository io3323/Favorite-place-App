
import UIKit
import MapKit
import CoreLocation

protocol MapViewControlerViewControllerDelegate{
    func getAddress(_ address:String?)
    
}
class MapViewControlerViewController: UIViewController {
    
    let mapManager = MapManager()
    var place = Place()
    var mapViewControllerDelegate:MapViewControlerViewControllerDelegate?
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifire = ""
    var previousLocation:CLLocation? {
        
        didSet{
            mapManager.startRackingUserLocation(
                for:mapView,
                   and: previousLocation){ (currentLocation) in
                       self.previousLocation = currentLocation
                       
                       DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                           self.mapManager.showUserLocation(mapView: self.mapView)
                       }
                       
                   }
        }
    }
    
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
      
    }
    @IBAction func senterViewInUserLocation(){
        mapManager.showUserLocation(mapView: mapView)
    }
    @IBAction func doneButtonPress(){
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    @IBAction func goButtonPressed(){
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
        
    }
    @IBAction func closeVC(){
        dismiss(animated: true)
    }
    
    private func setupMapView(){
        
        goButton.isHidden = true
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifire) {
            mapManager.locationManager.delegate = self
        }
        if incomeSegueIdentifire == "showPlace"{
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
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
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        
        if incomeSegueIdentifire == "showPlace" && previousLocation != nil{
            DispatchQueue.main.asyncAfter( deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        
        geocoder.cancelGeocode()
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
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager,didChangeAuthorization status:CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifire: incomeSegueIdentifire)
    }
}
