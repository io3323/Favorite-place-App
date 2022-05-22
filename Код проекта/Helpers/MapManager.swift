import UIKit
import MapKit
import Foundation
class MapManager{
    
    let locationManager = CLLocationManager()
    private let regionInMeters = 10_000.0
    private var directionsArray:[MKDirections] = []
    private var placeCoordinate:CLLocationCoordinate2D?
    
    func setupPlacemark(place: Place,mapView:MKMapView){
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated:true)
            
            
        }
    }
    
    func checkLocationServices(mapView:MKMapView, segueIdentifier:String, closure: () -> ()){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifire: segueIdentifier)
            closure()
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 ){
                
                self.showAlert(title: "Location Services are Disable", message: "To enable it go")
            }
        }
    }
    // Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifire: String){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifire == "getAddress" { showUserLocation(mapView:mapView)}
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
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView){
        
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    // Строим маршут от местоположения пользователя до заведения
    func getDirections(for mapView:MKMapView, previousLocation: (CLLocation) -> ()){
        
        guard  let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Curent location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        
        guard  let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval  = route.expectedTravelTime
                
                print("Rastonie do mesta: \(distance) km.")
                print("vrema v puti : \(timeInterval) sek.")
                
            }
        }
    }
    // Настройка запроса для расчета маршута
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
    // Меняем отображаемую зону области в соответствии с перемещением пользователя
   func startRackingUserLocation(for mapView:MKMapView, and location:CLLocation?, closure:(_ currentLocation:CLLocation) -> ()){
        guard let location = location else {return}
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else {return}
        
        closure(center)
      
    }
    //Сброс всех ранее построенных маршутов перед построением нового
    private func resetMapView(withNew directions: MKDirections, mapView:MKMapView){
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
        directionsArray.removeAll()
        
    }
    //Определие центра отоброжаемой области
    func getCenterLocation(for mapView:MKMapView) -> CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController =  UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
}
