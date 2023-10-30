//
//  UDBaseSectionsView.swift

import Foundation
import UIKit

class UDBaseSectionsView: UDListBaseKnowledgeVC {
    
    override func firstState() {
        titleVC = usedesk?.model.stringFor("KnowlengeBase") ?? ""
        super.firstState()
        if !(usedesk?.model.isPresentDefaultControllers ?? true) {
            backButton.alpha = 0
            backButtonWC.constant = 0
        }
        
        tableView.register(UINib(nibName: "UDBaseSectionViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseSectionViewCell")
        tableView.reloadData()
    }
    
    override func updateValues() {
        isUpdatedValues = true
        if usedesk?.model.isLoadedKnowledgeBase ?? false {
            arrayCollections = usedesk?.model.baseSections ?? []
            downloadImagesSection()
        }
    }
    
    // MARK: - Private
    private func getData(from url: URL, index: Int, completion: @escaping (Data?, URLResponse?, Int, Error?) -> ()) {
        (URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            completion(data, response, index, error)
        })).resume()
    }
    
    private func downloadImagesSection() {
        var urlsDictionary:[Int : URL] = [:]
        for index in 0..<arrayCollections.count {
            if let url = URL(string: arrayCollections[index].imageUrl) {
                urlsDictionary[index] = url
            }
        }
        var countResponse = 0
        for urlDictionary in urlsDictionary {
            getData(from: urlDictionary.value, index: urlDictionary.key) { data, response, index, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { [weak self] in
                    countResponse += 1
                    self?.arrayCollections[urlDictionary.key].image = UIImage(data: data)
                    if countResponse == urlsDictionary.count {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - TableView
    override func countCell() -> Int {
        return arrayCollections.count
    }
    
    override func getCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDBaseSectionViewCell", for: indexPath) as! UDBaseSectionViewCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        cell.setCell(text: arrayCollections[indexPath.row].title, image: arrayCollections[indexPath.row].image)
        return cell
    }
    
    override func selectRowAt(_ indexPath: IndexPath) {
        guard usedesk != nil else {return}
        let baseCategoriesVC: UDBaseCategoriesView = UDBaseCategoriesView()
        baseCategoriesVC.usedesk = usedesk!
        baseCategoriesVC.titleVC = arrayCollections[indexPath.row].title
        baseCategoriesVC.сategories = arrayCollections[indexPath.row].categories
        usedesk?.uiManager?.pushViewController(baseCategoriesVC)
        if let cell = tableView.cellForRow(at: indexPath) as? UDBaseSectionViewCell {
            cell.isSelected = false
            cell.selectionStyle = .none
        }
    }
}
