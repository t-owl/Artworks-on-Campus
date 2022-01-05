//
//  MultipleArtworksSelectionViewController.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//

import UIKit

class MultipleArtworksSelectionViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    var groupedArtwork:GroupedArtworks?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = groupedArtwork?.locationName ?? ""
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let detailPageViewController:DetailPageViewController = segue.destination as? DetailPageViewController {
                detailPageViewController.artwork = groupedArtwork?.artworks[tableView.indexPathForSelectedRow?.row ?? 0]
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MultipleArtworksSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
}

extension MultipleArtworksSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedArtwork?.artworks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let artwork = groupedArtwork?.artworks[indexPath.row] {
            cell.textLabel?.text = artwork.title
            cell.detailTextLabel?.text = artwork.artist
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedArtwork?.locationName
    }
}
