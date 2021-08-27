//
//  UDOfflineFormTopicsSelect.swift
//  UseDesk_SDK_Swift


import UIKit

protocol UDOfflineFormTopicsSelectDelegate: class {
    func selectedTopic(indexTopic: Int?)
}

class UDOfflineFormTopicsSelect: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var usedesk: UseDeskSDK?
    weak var delegate: UDOfflineFormTopicsSelectDelegate?
    
    var selectedIndexPath: IndexPath? = nil
    var topics: [UDCallbackTopic] = []
    
    private var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    private var isFirstOpen = true
    private var previousOrientation: Orientation = .portrait
    
    convenience init() {
        let nibName: String = "UDOfflineFormTopicsSelect"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isFirstOpen else {
            isFirstOpen = false
            return
        }
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            if previousOrientation != .portrait {
                previousOrientation = .portrait
                self.view.endEditing(true)
            }
        } else {
            if previousOrientation != .landscape {
                previousOrientation = .landscape
                self.view.endEditing(true)
            }
        }
    }
    
    
    // MARK: - Private
    func firstState() {
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        let selectTopicFeedbackFormStyle = configurationStyle.selectTopicFeedbackFormStyle
        title = usedesk?.callbackSettings.titleTopics ?? "Тема обращения"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonImage, style: .plain, target: self, action: #selector(self.backAction))
        tableView.register(UINib(nibName: "UDSimpleSelectCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDSimpleSelectCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    @objc func backAction() {
        delegate?.selectedTopic(indexTopic: selectedIndexPath?.row)
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - UITableViewDelegate
extension UDOfflineFormTopicsSelect: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDSimpleSelectCell", for: indexPath) as! UDSimpleSelectCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        cell.setCell(title: topics[indexPath.row].text)
        if indexPath == selectedIndexPath {
            cell.setSelected()
        } else {
            cell.setNotSelected()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = selectedIndexPath != indexPath ? indexPath : nil
        tableView.reloadData()
    }
}
