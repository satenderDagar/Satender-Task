//
//  FilterCollectionViewController.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import UIKit
import Combine

protocol FilterUpdaterDelegate: AnyObject {
    func didChangeSelectedFilters(filters: [Filter])
}

class FilterCollectionViewController: UICollectionViewController {
    
    var viewModel = FilterViewModel()
    var cancellable = Set<AnyCancellable>()
    weak var filterUpdaterDelegate: FilterUpdaterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        observeFilters()
    }
        
    private func setupCollectionView() {
        collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: FilterCollectionViewCell.reuseIdentifier)
        
        let filterCustomLayout = FilterCustomLayout()
        filterCustomLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = filterCustomLayout
        
        collectionView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView.reloadData()
    }
    
    private func observeFilters() {
        viewModel.$filters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }.store(in: &cancellable)
        
        viewModel.selectedFilters
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectedfilters in
                self?.filterUpdaterDelegate?.didChangeSelectedFilters(filters: selectedfilters)
            }).store(in: &cancellable)
    }
}

// MARK: UICollectionViewDataSource
extension FilterCollectionViewController{
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filters.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.reuseIdentifier, for: indexPath) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModel.filters[indexPath.row])
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.toggleSelection(for: viewModel.filters[indexPath.row])
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.toggleSelection(for: viewModel.filters[indexPath.row])
    }
}
