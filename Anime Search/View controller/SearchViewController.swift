//
//  SearchViewController.swift
//  Anime Search
//
//  Created by 林祐辰 on 2021/1/4.
//

import UIKit
import SafariServices
import CoreData

class SearchViewController: UIViewController,UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{
      

    var searchController:UISearchController!
    
    @IBOutlet weak var searchView: UITableView!
    @IBOutlet weak var selectedSegment: UISegmentedControl!
    
    
    let activityIndicator = UIActivityIndicatorView()
    var type:String? = "anime"
    var clientSide:GetDatasFromJikan = AnimeDataFromJikan.shared
    var fetchSearchTask :URLSessionDataTask?
    
    var animeResults = [SearchResults]()
    var mangaResults = [SearchResults]()
    var personResults = [SearchResults]()
    var characterResults = [SearchResults]()

    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selection = 0
    
    var saveSearchedAnime :[FavoriteAnime]?
    var saveSearchedMagna :[FavoriteManga]?
    var saveSearchedPerson :[FavoritePerson]?
    var saveSearchedCharacter :[FavoriteCharacter]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.delegate = self
        searchView.dataSource = self
        searchView.isHidden = true
        searchControllerHelper()
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupActivityIndicator()
    }
    var bannedSearchWords = ["Loli", "Lolita", "Lolicon", "Roricon", "Shotacon",
                             "Shota", "Yaoi", "Ecchi", "Hentai", "loli", "lolita",
                             "lolicon", "roricon","shotacon", "shota", "yaoi",
                             "ecchi", "hentai"]
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        view.addConstraint(verticalConstraint)
    }
    
    func searchControllerHelper(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Anime, Manga, Character, or Person"
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.tintColor = .black
        searchController.searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if bannedSearchWords.contains(searchBar.text!){
            let alert = UIAlertController(title: "You can't search for this type of content.", message: "The content you typed is banned on the app store and can not be shown.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "All right", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }else{
            self.activityIndicator.startAnimating()
            getSearchedAnime()
            getSearchedManga()
            getSearchedPerson()
            getSearchedCharacter()
        }
    }
    
    func getSearchedAnime(){
        type = "anime"
        fetchSearchTask = clientSide.getSearchResult(type: type!, keyword:  searchController.searchBar.text, completion: {[self]  (searchTopAnime, error) in
            self.fetchSearchTask = nil
            if let _ = error{
                self.errorMessage()
            }
            
            if let searchedResult = searchTopAnime?.results{
                self.animeResults.append(contentsOf: searchedResult)
                DispatchQueue.main.async {
                      self.searchView.reloadData()
                      self.activityIndicator.stopAnimating()
                      self.searchView.isHidden = false
                 }
            }
        })
    }
    
    func getSearchedManga(){
        type = "manga"
        fetchSearchTask = clientSide.getSearchResult(type: type!, keyword: searchController.searchBar.text, completion: { [self] (searchTopAnime, error) in
            self.fetchSearchTask = nil
            if let _ = error{
                self.errorMessage()
            }

            if let searchResult = searchTopAnime?.results{
                self.mangaResults.append(contentsOf: searchResult)
                DispatchQueue.main.async {
                    self.searchView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.searchView.isHidden = false
                }
            }
        })
    }
    
    func getSearchedPerson(){
        type = "person"
        fetchSearchTask = clientSide.getSearchResult(type: type!, keyword:  searchController.searchBar.text, completion: { [self] (searchTopAnime, error) in
            self.fetchSearchTask = nil
            if let _ = error{
                self.errorMessage()
            }

            if let searchResult = searchTopAnime?.results{
                self.personResults.append(contentsOf: searchResult)
                DispatchQueue.main.async {
                    self.searchView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.searchView.isHidden = false
                }
            }
        })
    }

    func getSearchedCharacter(){
        type = "character"
    fetchSearchTask = clientSide.getSearchResult(type: type!, keyword:  searchController.searchBar.text, completion: {[self] (searchTopAnime, error) in
            self.fetchSearchTask = nil
            if let _ = error{
                self.errorMessage()
            }

            if let searchResult = searchTopAnime?.results{
                self.characterResults.append(contentsOf: searchResult)
                DispatchQueue.main.async {
                    self.searchView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.searchView.isHidden = false
                }
            }
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            searchView.isHidden = true
            animeResults.removeAll()
            mangaResults.removeAll()
            personResults.removeAll()
            characterResults.removeAll()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedSegment.selectedSegmentIndex {
            case 0:
              return animeResults.count
            case 1:
              return mangaResults.count
            case 2:
              return personResults.count
            case 3:
              return characterResults.count
            default:
              return animeResults.count
        }
    }
    
    var isFavorite:Bool = false
    var cellImage = UIImage(named: "heart")

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchView.dequeueReusableCell(withIdentifier: "searchTableViewCell", for: indexPath) as? SearchTableViewCell
        let number = indexPath.row
        var results :SearchResults
        
            if selectedSegment.selectedSegmentIndex == 0{
                results = animeResults[number]
                selection = animeResults[number].identity
                cell?.resultSearchName.text = results.title
                cell?.resultImage.image = UIImage(contentsOfFile:"MAL")
                
                if let url = URL(string: results.imageURL){
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        if let data = data{
                            DispatchQueue.main.async {
                                cell?.resultImage.image = UIImage(data: data)
                            }
                        }
                    }).resume()
                }
                
                
            }else if selectedSegment.selectedSegmentIndex == 1{
                results = mangaResults[number]
                selection = mangaResults[number].identity
                cell?.resultSearchName.text = results.title
                cell?.resultImage.image = UIImage(contentsOfFile:"MAL")
                
                if let url = URL(string: results.imageURL){
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        if let data = data{
                            DispatchQueue.main.async {
                                cell?.resultImage.image = UIImage(data: data)
                            }
                        }
                    }).resume()
                }
            }else if selectedSegment.selectedSegmentIndex == 2{
                results = personResults[number]
                selection = personResults[number].identity
                
                cell?.resultSearchName.text = results.name
                cell?.resultImage.image = UIImage(contentsOfFile:"MAL")
                
                if let url = URL(string: results.imageURL){
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        if let data = data{
                            DispatchQueue.main.async {
                                cell?.resultImage.image = UIImage(data: data)
                            }
                        }
                    }).resume()
                }
            }else if selectedSegment.selectedSegmentIndex == 3{
                results = characterResults[number]
                selection = characterResults[number].identity
                
                cell?.resultSearchName.text = results.name
                cell?.resultImage.image = UIImage(contentsOfFile:"MAL")
                
                
                if let url = URL(string: results.imageURL){
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        if let data = data{
                            DispatchQueue.main.async {
                                cell?.resultImage.image = UIImage(data: data)
                            }
                        }
                    }).resume()
                }
            }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let results :SearchResults
        
         if selectedSegment.selectedSegmentIndex == 0 {
            let newFavoriteAnime = NSEntityDescription.insertNewObject(forEntityName: "FavoriteAnime", into: context) as! FavoriteAnime
                results = animeResults[indexPath.row]
                let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
                let addToFavorite = UIAlertAction(title: "Add to Favorite Anime", style: .default) { (action) in
               
                    newFavoriteAnime.name = results.title
                    newFavoriteAnime.imageUrl = results.imageURL
                    newFavoriteAnime.identity = Float(results.identity)
                    newFavoriteAnime.isSaved = true
                    self.container.checkIfDuplicate(FavoriteAnime.self, identity: newFavoriteAnime.identity)
                    self.container.saveContext()
                    
                }
                let goToWebPage = UIAlertAction(title: "See Anime Details..", style: .default) { (action) in
                    if let url = URL(string: results.url){
                        let safari = SFSafariViewController(url: url)
                        self.present(safari, animated: true, completion: nil)
                        }
                    self.container.checkIfExists(FavoriteAnime.self, identity: newFavoriteAnime.identity)
                }
            
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    self.container.checkIfExists(FavoriteAnime.self, identity: newFavoriteAnime.identity)
                }
            
                optionMenu.addAction(addToFavorite)
                optionMenu.addAction(goToWebPage)
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)
        
         }else if selectedSegment.selectedSegmentIndex == 1 {
            let newFavoriteMagna = NSEntityDescription.insertNewObject(forEntityName: "FavoriteManga", into: context) as! FavoriteManga
                results = mangaResults[indexPath.row]
                let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
                let addToFavorite = UIAlertAction(title: "Add to Favorite Magna", style: .default) { (action) in
                    newFavoriteMagna.name = results.title
                    newFavoriteMagna.imageUrl = results.imageURL
                    newFavoriteMagna.identity = Float(results.identity)
                    newFavoriteMagna.isSaved = true
                    self.container.saveContext()
                    print("RRRRRR \(newFavoriteMagna)")
            }
            
                let goToWebPage = UIAlertAction(title: "See Manga Details..", style: .default) { (action) in
                   if let url = URL(string: results.url){
                   let safari = SFSafariViewController(url: url)
                   self.present(safari, animated: true, completion: nil)
                }
                    self.container.checkIfExists(FavoriteManga.self, identity: newFavoriteMagna.identity)
            }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    self.container.checkIfExists(FavoriteManga.self, identity: newFavoriteMagna.identity)
                }
        
               optionMenu.addAction(addToFavorite)
               optionMenu.addAction(goToWebPage)
               optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
            
         }else if selectedSegment.selectedSegmentIndex == 2 {
            let newFavoritePerson = NSEntityDescription.insertNewObject(forEntityName: "FavoritePerson", into: context) as! FavoritePerson
                results = personResults[indexPath.row]
                let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
                let addToFavorite = UIAlertAction(title: "Add to Favorite Person", style: .default) { (action) in
                    newFavoritePerson.name = results.name
                    newFavoritePerson.imageUrl = results.imageURL
                    newFavoritePerson.identity = Float(results.identity)
                    newFavoritePerson.isSaved = true
                    self.container.saveContext()
                    print("RRRRRR \(newFavoritePerson)")
        }
                let goToWebPage = UIAlertAction(title: "See Person Details..", style: .default) { (action) in
                   if let url = URL(string: results.url){
                   let safari = SFSafariViewController(url: url)
                   self.present(safari, animated: true, completion: nil)
                }
                    self.container.checkIfExists(FavoritePerson.self, identity: newFavoritePerson.identity)
            }
            
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
                    self.container.checkIfExists(FavoritePerson.self, identity: newFavoritePerson.identity)
                }
            
                optionMenu.addAction(addToFavorite)
                optionMenu.addAction(goToWebPage)
                optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
            
         }else if selectedSegment.selectedSegmentIndex == 3{
            let newFavoriteCharacter = NSEntityDescription.insertNewObject(forEntityName: "FavoriteCharacter", into: context) as! FavoriteCharacter
                results = characterResults[indexPath.row]
                let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
                let addToFavorite = UIAlertAction(title: "Add to Favorite Character", style: .default) { (action) in
                    newFavoriteCharacter.name = results.name
                    newFavoriteCharacter.imageUrl = results.imageURL
                    newFavoriteCharacter.identity = Float(results.identity)
                    newFavoriteCharacter.isSaved = true
                    self.container.saveContext()
                    print("RRRRRR \(newFavoriteCharacter)")

          }
                let goToWebPage = UIAlertAction(title: "See Character Details..", style: .default) { (action) in
                   if let url = URL(string: results.url){
                   let safari = SFSafariViewController(url: url)
                   self.present(safari, animated: true, completion: nil)
                }
                    self.container.checkIfExists(FavoriteCharacter.self, identity: newFavoriteCharacter.identity)
            }
            
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
                    self.container.checkIfExists(FavoriteCharacter.self, identity: newFavoriteCharacter.identity)
                }
            
               optionMenu.addAction(addToFavorite)
               optionMenu.addAction(goToWebPage)
               optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
         }
     
    }

    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
            DispatchQueue.main.async {
                self.searchView.reloadData()
            }
        }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text != nil {
            if selectedSegment.selectedSegmentIndex == 0{
                DispatchQueue.main.async {
                    self.searchView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }else if selectedSegment.selectedSegmentIndex == 1{
                DispatchQueue.main.async {
                    self.searchView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }else if selectedSegment.selectedSegmentIndex == 2{
                DispatchQueue.main.async {
                    self.searchView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }else if selectedSegment.selectedSegmentIndex == 3{
                DispatchQueue.main.async {
                    self.searchView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }else if searchController.searchBar.text?.count == 0{
            searchView.isHidden = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           animeResults.removeAll()
           mangaResults.removeAll()
           personResults.removeAll()
           characterResults.removeAll()
    }
    
    func errorMessage(){
        let alertController = UIAlertController(title: "Error", message: "Can't load Search Item", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

