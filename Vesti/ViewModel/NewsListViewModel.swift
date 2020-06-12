//
//  VestiListViewModel.swift
//  Vesti
//
//  Created by Yuriy Balabin on 10.06.2020.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation


protocol NewsListViewModelType: class {
    
    var updateNewsFlag: Box<Bool> { get set }
    var filterdResultIsNullFlag: Bool { get set }
    var onSelectFilter: (() -> Void)? { get set }
    func numberOfItems() -> Int
    func filterNews()
    func cellViewModel(forIndexPath indexPath: IndexPath) -> NewsCellViewModelType?
    func getNews()
    init(networkService: NetworkServiceProtocol)
}


class NewsListViewModel: NewsListViewModelType {
    
    
    var newsList = [News]()
    var filtredNewsList = [News]()
    var filterdResultIsNullFlag = false
    
    var networkService: NetworkServiceProtocol
    
    var updateNewsFlag: Box<Bool> = Box(false)
   
    var onSelectFilter: (() -> Void)?
    
    func numberOfItems() -> Int {
        if filterdResultIsNullFlag {
            return 0
        }
        
        return filtredNewsList.isEmpty ? newsList.count : filtredNewsList.count
    }
    
    func filterNews() {
        let categories = UserDefaults.standard.value(forKey: "selectedCategories") as? [String] ?? [String()]
        
        filtredNewsList = newsList.filter { categories.contains($0.category) }
        
        if filtredNewsList.isEmpty && !categories.isEmpty {
           filterdResultIsNullFlag = true
        }
        
    }
    
    func cellViewModel(forIndexPath indexPath: IndexPath) -> NewsCellViewModelType? {
        let news: News
        
        if !filtredNewsList.isEmpty {
           news = filtredNewsList[indexPath.row]
        } else {
            news = newsList[indexPath.row]
        }
       
        
        let cellViewModel = NewsCellViewModel(news: news)
        return cellViewModel
    }
    
    func getNews() {
        networkService.getNews { result in
            DispatchQueue.main.async {
                
                switch result {
                case .failure(let error):
                    print(error)
                    
                case .success(let newsList):
                    
                    guard let newsList = newsList else { return }
                
                    self.newsList = newsList
                    self.filterNews()
                    self.updateNewsFlag.value.toggle()
                    
               //   print(newsList)
//                   for i in newsList {
//                       print(i.category)
//                    }
                }
                
            }
        }
    }
    
    required init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
}
