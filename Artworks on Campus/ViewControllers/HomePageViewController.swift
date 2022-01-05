//
//  ViewController.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//

import UIKit
import MapKit

class HomePageViewController: UIViewController {
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var tableViewTopConstraint:NSLayoutConstraint!
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    var groupedArtworks = [GroupedArtworks]()
    var selectedGroupedArtworks = [GroupedArtworks]()
    var selectedArtwork:Artworks?
    var selectionAnnotationTag:Int = 0
    var searchController = UISearchController()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        mapView.showsUserLocation = true
        tableView.keyboardDismissMode = .onDrag
        NotificationCenter.default.addObserver(self, selector: #selector(self.dataUpdated), name: Notification.Name(DataSyncManager.dataUpdatedNotification), object: nil)
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.delegate = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            //Add searchbar controller in header
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()

        self.enableLocationManager()
        self.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dataUpdated() {
        self.reloadData()
    }
    
    func reloadData() {
        if let artworks =  Artworks.getAllArtworksInLocationSortOrder(with: currentLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) {
            groupedArtworks = self.reloadDataWithArtworks(artworks)
        }
        self.tableView.reloadData()
        self.updateAnnotation()
    }
    
    func reloadDataWithArtworks(_ artworks:[Artworks]) -> [GroupedArtworks]{
        var groupedArtworks = [GroupedArtworks]()
        var lastDistance:Double = 0.0
        for artwork in artworks {
            if artwork.distance - lastDistance < 0.02 {
                if let groupedArtwork = groupedArtworks.last {
                    groupedArtwork.artworks.append(artwork)
                }
            } else {
                let groupedArtwork = GroupedArtworks()
                groupedArtwork.artworks = [artwork]
                groupedArtwork.locationName = artwork.locationNotes ?? ""
                groupedArtwork.location = CLLocationCoordinate2D(latitude: artwork.lat, longitude: artwork.long)
                groupedArtworks.append(groupedArtwork)
            }
            lastDistance = artwork.distance
        }
        return groupedArtworks
    }
    
    
    func updateAnnotation() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        for (index, groupedArtwork) in groupedArtworks.enumerated() {
            let annotation = CustomPointAnnotation()
            annotation.title = groupedArtwork.locationName
            annotation.coordinate = groupedArtwork.location
            annotation.tag = index
            mapView.addAnnotation(annotation)
        }
    }
    
    func enableLocationManager() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        if let userLocation = locationManager.location?.coordinate {
            currentLocation = userLocation
            self.zoomToCurrentLocation()
        }
        
        self.locationManager = locationManager
        DispatchQueue.main.async {
            self.locationManager?.startUpdatingLocation()
        }

    }
    
    func zoomToCurrentLocation() {
        if let currentLocation = currentLocation {
            let viewRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(viewRegion, animated: false)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let detailPageViewController:DetailPageViewController = segue.destination as? DetailPageViewController {
                detailPageViewController.artwork = selectedArtwork
            }
        } else if segue.identifier == "multipleArtworks" {
            if let multipleArtworksSelectionViewController:MultipleArtworksSelectionViewController = segue.destination as? MultipleArtworksSelectionViewController {
                multipleArtworksSelectionViewController.groupedArtwork = groupedArtworks[selectionAnnotationTag]
            }
        }
    }

    func getActiveGroupedArtworks() -> [GroupedArtworks]{
        if self.searchController.isActive {
            return selectedGroupedArtworks
        }
        return groupedArtworks
    }
}

extension HomePageViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
        self.reloadData()
        self.zoomToCurrentLocation()
    }
}

extension HomePageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedArtwork = self.getActiveGroupedArtworks()[indexPath.section].artworks[indexPath.row]
        self.view.endEditing(true)
        if searchController.isActive {
                self.searchController.isActive = false
        }
        self.performSegue(withIdentifier: "showDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomePageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getActiveGroupedArtworks()[section].artworks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let artwork = getActiveGroupedArtworks()[indexPath.section].artworks[indexPath.row]
        cell.textLabel?.text = artwork.title
        cell.detailTextLabel?.text = artwork.artist
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getActiveGroupedArtworks().count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getActiveGroupedArtworks()[section].locationName
    }
}

extension HomePageViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            let btn = UIButton(type: .detailDisclosure)
            annotationView!.rightCalloutAccessoryView = btn
        } else {
            annotationView!.annotation = annotation
        }
        if let annotation = annotation as? CustomPointAnnotation {
            annotationView?.tag = annotation.tag
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if groupedArtworks[view.tag].artworks.count == 1 {
            selectedArtwork = groupedArtworks[view.tag].artworks.first
            self.performSegue(withIdentifier: "showDetail", sender: self)
        } else {
            selectionAnnotationTag = view.tag
            self.performSegue(withIdentifier: "multipleArtworks", sender: self)
        }
    }

}

extension HomePageViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let artworks =  Artworks.getAllArtworksInLocationSortOrder(with: currentLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), text: searchController.searchBar.text ?? "") {
            selectedGroupedArtworks = self.reloadDataWithArtworks(artworks)
            tableView.reloadData()
        }
    }
}

extension HomePageViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        tableViewTopConstraint.constant = -1*mapView.bounds.size.height
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableViewTopConstraint.constant = 0
    }
}
