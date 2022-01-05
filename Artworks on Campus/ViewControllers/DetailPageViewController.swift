//
//  DetailPageViewController.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//

import UIKit

class DetailPageViewController: UIViewController {
    @IBOutlet weak var artworkTitle: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var artworkArtist: UILabel!
    @IBOutlet weak var artworkYearOfWork: UILabel!
    @IBOutlet weak var artworkInformation: UILabel!
    var artwork: Artworks?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        if let artwork = artwork {
            artworkTitle.text = artwork.title
            artworkArtist.text = artwork.artist
            artworkYearOfWork.text = artwork.yearOfWork
            artworkInformation.text = artwork.information
            artworkImageView.cacheImage(urlString: NetworkManager.imageBaseURL + (artwork.fileName ?? ""))
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
