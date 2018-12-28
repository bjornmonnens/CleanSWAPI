//
//  PlanetsViewController.swift
//  Planets
//
//  Created by Dieter Vogels on 23/12/2018.
//  Copyright © 2018 Jidoka BVBA. All rights reserved.
//

import Foundation
import Common

protocol PlanetsViewControllerDelegate: class {
    
    func controllerWillDissappear(_ controller: PlanetsViewController)
    
}

class PlanetsViewController : UITableViewController {
    
    //MARK: - Properties
    
    private let viewModel: PlanetsViewModel
    weak var delegate: PlanetsViewControllerDelegate?
    
    //MARK: - Init
    
    init(viewModel: PlanetsViewModel) {
        self.viewModel = viewModel
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Planets"
        
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        viewModel.refreshHandler = { [weak self] in
            self?.refresh()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchPlanets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.controllerWillDissappear(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adjustFooterViewHeightToFillTableView()
    }
    
    private lazy var loadingView: UIView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .gray
        activityIndicatorView.startAnimating()
        
        return activityIndicatorView
    }()
        
}

//MARK: - Methods

extension PlanetsViewController {
    
    func refresh() {
        switch viewModel.state {
        case .loading, .paging:
            tableView.tableFooterView = loadingView
        case .populated:
            tableView.tableFooterView = UIView()
        case .empty:
            tableView.tableFooterView = EmptyView()
        case .error(let error):
            tableView.tableFooterView = ErrorView(error: error)
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource

extension PlanetsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.state.objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.textLabel?.text = viewModel.state.objects[indexPath.row].name
        
        let isLastRow = indexPath.row == viewModel.state.objects.count - 1
        if isLastRow {
            viewModel.loadNextPageWhenNeeded()
        }
        
        return cell
    }
    
}
