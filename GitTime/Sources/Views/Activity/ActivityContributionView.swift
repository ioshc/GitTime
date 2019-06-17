//
//  ActivityContributionView.swift
//  GitTime
//
//  Created by Kanz on 17/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit

class ActivityContributionView: UIView, View {
    
    typealias Reactor = ActivityContributionViewReactor
    
    // MARK: - UI
    private let contributionCountLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 10.0, height: 10.0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.itemSize = CGSize(width: 5.0, height: 5.0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerNib(cellType: ContributionCell.self)
        
        return collectionView
    }()
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    static var dataSource: RxCollectionViewSectionedReloadDataSource<ContributionSection> {
        return .init(configureCell: { (datasource, collectionView, indexPath, sectionItem) -> UICollectionViewCell in
            switch sectionItem {
            case .contribution(let reactor):
                let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ContributionCell.self)
                cell.reactor = reactor
                return cell
            }
        })
    }
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<ContributionSection> = type(of: self).dataSource
    var layoutSubViewsFirstTime: Bool = true
    
    // MARK: - View Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contributionCountLabel)
        self.addSubview(collectionView)
        
        contributionCountLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(16.0)
            make.trailing.equalTo(-16.0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contributionCountLabel.snp.bottom).offset(8.0)
            make.leading.equalTo(16.0)
            make.trailing.bottom.equalTo(-16.0)
            make.height.equalTo(47.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if layoutSubViewsFirstTime, collectionView.contentSize.width > 0.0 {
            layoutSubViewsFirstTime = false
            let offSet = collectionView.contentSize.width - collectionView.frame.width
            self.collectionView.setContentOffset(CGPoint(x: offSet, y: 0.0), animated: false)
        }
    }
    
    fileprivate func updateUI(_ state: Reactor.State) {
        let count = state.contributionInfo.count
        contributionCountLabel.text = "\(count) contributions in the last year"
    }
    
    func bind(reactor: Reactor) {
        
        // State
        reactor.state
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.updateUI(state)
            }).disposed(by: self.disposeBag)
        
        reactor.state.map { $0.sections }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        // View
        self.collectionView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
    }
}

extension ActivityContributionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 5.0, height: 5.0)
    }
}