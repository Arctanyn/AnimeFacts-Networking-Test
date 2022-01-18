//
//  AnimeListViewController.swift
//  AnimeFacts-Alamofire
//
//  Created by Малиль Дугулюбгов on 18.01.2022.
//

import UIKit

private let animeDataURL = "https://anime-facts-rest-api.herokuapp.com/api/v1"
private var factsURL = "https://anime-facts-rest-api.herokuapp.com/api/v1/"
private let reuseIdentifier = "animeCell"

class AnimeListViewController: UICollectionViewController {
    
    //MARK: - Properties
    private var animeList = [AnimeExample]()
    
    
    //MARK: - View
    @IBOutlet weak var reloadDataButton: UIButton!
    @IBOutlet weak var dataLoadingIndicatorView: UIActivityIndicatorView!
    
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = .zero
        self.title = "Anime list"
        
        dataLoadingIndicatorView.hidesWhenStopped = true
        
        checkConnection()
        loadAnimeData()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let animeFactsVC = segue.destination as? AnimeFactsViewController else { return }
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! AnimeCollectionViewCell
        let anime = animeList[indexPath.item]
        let currentAnimeFactsURL = factsURL + (anime.anime_name ?? "")
        
        animeFactsVC.image = selectedCell.animeCoverImageView.image
        animeFactsVC.title = selectedCell.animeTitleLabel.text
        animeFactsVC.fetchFacts(from: currentAnimeFactsURL)
    }
    
    //MARK: - Networking
    private func loadAnimeData() {
        dataLoadingIndicatorView.startAnimating()
        guard let url = URL(string: animeDataURL) else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let response = response {
                print(response)
            }
            
            guard let data = data else { return }
            do {
                let animeData = try JSONDecoder().decode(AnimeData.self, from: data)
                self.animeList = animeData.data ?? []
                DispatchQueue.main.async { [weak self] in
                    self?.dataLoadingIndicatorView.stopAnimating()
                    self?.collectionView.reloadData()
                }
            } catch {
                print(error)
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(with: "Error", and: "Data can't be load")
                }
            }
        }.resume()
    }
    
    @IBAction func reloadDataTapped(_ sender: UIButton) {
        reloadDataButton.isHidden = true
        loadAnimeData()
    }
}

// MARK: - UICollectionViewDataSource
extension AnimeListViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AnimeCollectionViewCell
        
        if !animeList.isEmpty {
            let anime = animeList[indexPath.item]
            cell.updateView(with: anime)
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension AnimeListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemPerRow = CGFloat(2)
        let paddingWidth = 5 * (itemPerRow + 1)
        let avaibleWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = avaibleWidth / itemPerRow
        return CGSize(width: widthPerItem, height: widthPerItem + 100)
    }
}

//MARK: - Priavate methods
extension AnimeListViewController {
    private func checkConnection() {
        if !NetworkMonitor.shared.isConnected {
            showAlert(with: "Something wrong with your internet connection", and: "Please connect to the network or try again later")
        } else {
            reloadDataButton.isHidden = true
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertOKAction)
        self.present(alert, animated: true) { [dataLoadingIndicatorView, reloadDataButton] in
            dataLoadingIndicatorView?.stopAnimating()
            reloadDataButton?.isHidden = false
        }
    }
}
