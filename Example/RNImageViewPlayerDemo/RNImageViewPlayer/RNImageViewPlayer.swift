//
//  RNImageViewPlayer.swift
//  RNImageViewPlayer
//
//  Created by rainedAllNight on 2017/2/1(🐔年大吉吧)
//  Copyright © 2017年 rainedAllNight. All rights reserved.
//

import UIKit

public enum PageControlPosition {
    case topLeft
    case topCenter
    case topRight
    case bottomLeft
    case bottomCenter
    case bottomRight
    case custom(String, String) // you need use VFL string to set the layout
}

@objc public protocol RNImageViewPlayerDelegate {
    // return the datasouce count, images count
    // 返回数据源大小
    func imagePlayerNumberOfItems(imagePlayer: RNImageViewPlayer) -> Int
    
    // return the custom cell, and you need set the imageView in this func
    // 返回自定义的cell
    @objc optional func imagePlayer(imagePlayer: RNImageViewPlayer, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    // when you are use the default cell, you need set the imageView in this func
    // 将要展示某个imageView, imageView 的操作可以在这里进行(使用defaultCell才会触发此回调)
    @objc optional func imagePlayer(imagePlayer: RNImageViewPlayer, willLoadDefaultCellImageWith imageView: UIImageView, at index: Int)
    
    // did scroll at some item
    // 滑动到某个item
    @objc optional func imagePlayer(imagePlayer: RNImageViewPlayer, didScrollAt index: Int)
    
    // did select item at index 
    // 选中某个Item
    @objc optional func imagePlayer(imagePlayer: RNImageViewPlayer, didSelectItemAt index: Int)
}

extension RNImageViewPlayerDelegate {
    func imagePlayer(imagePlayer: RNImageViewPlayer, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let defaultCell = imagePlayer.collectionView?.dequeueReusableCell(withReuseIdentifier: "defaultCellReuseId", for: indexPath) as! RNImageViewPlayerCell
        return defaultCell
    }
}

class RNImageViewPlayerCell: UICollectionViewCell {
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        self.imageView = imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

open class RNImageViewPlayer: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public var collectionView: UICollectionView?
    public var timer: Timer?
    public var pageControl: UIPageControl?
    weak open var delegate: RNImageViewPlayerDelegate? {
        didSet {
            self.initUI()
        }
    }
    
    open var scrollInterval: Double = 2.5 // scroll interval, default is 2 seconds, set 0 to close scroll
    open var isHidePageControl = false // // hide pageControl, default is false
    open var isAutomaticScroll = true // is need automatic scroll, default is true
    open var isEndlessScroll = true // is endless scroll, defaul is true
    open var pageControlPosition: PageControlPosition = .bottomCenter // pageControl postion, default is bottom right
    open var currentPgaeIndex = 0 // current index of items, default is first = 0
    private var itemCount = 0
    private var defaultImageViewCell: RNImageViewPlayerCell?
    
    
    // MARK: - View life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    // MARK: - Private method 
    
    private func initUI() {
        self.itemCount = self.delegate?.imagePlayerNumberOfItems(imagePlayer: self) ?? 0
        
        if self.itemCount == 1 {
            // when itemCount is only one, hide the pageControl
            self.pageControl?.isHidden = true
        } else {
            self.pageControl?.isHidden = self.isHidePageControl
        }
        
        if self.itemCount <= 1 {
            // when itemCount is only one, don't add timer
            self.isAutomaticScroll = false
        } else {
           self.isAutomaticScroll = true
        }
        
        self.initCollectionView()
        self.initPageControl()
        
        weak var weakSelf = self
        if isAutomaticScroll, scrollInterval > 0, self.timer == nil {
            self.timer = Timer(timeInterval: scrollInterval, repeats: true, block: { (timer) in
                weakSelf?.timerAction()
            })
            CFRunLoopAddTimer(CFRunLoopGetCurrent(), self.timer, CFRunLoopMode.commonModes)
        }
        
        self.collectionView?.reloadData()
    }
    
    private func initCollectionView() {
        guard self.collectionView == nil else {
            return
        }
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: self.bounds.width, height: self.bounds.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false 

        self.addSubview(collectionView)
        self.collectionView = collectionView
        
        self.collectionView?.register(RNImageViewPlayerCell.self, forCellWithReuseIdentifier: "defaultCellReuseId")
    }
    
    private func initPageControl() {
        guard self.pageControl == nil else {
            self.pageControl?.numberOfPages = self.itemCount
            return
        }
        
        var vFormat = ""
        var hFormat = ""
        
        switch self.pageControlPosition {
        case .topLeft:
            vFormat = "V:|-0-[pageControl]"
            hFormat = "H:|-[pageControl]"
            
        case .topCenter:
            vFormat = "V:|-0-[pageControl]"
            hFormat = "H:|[pageControl]|"
            
        case .topRight:
            vFormat = "V:|-0-[pageControl]"
            hFormat = "H:[pageControl]-|"
            
        case .bottomLeft:
            vFormat = "V:[pageControl]-0-|"
            hFormat = "H:|-[pageControl]"
            
        case .bottomCenter:
            vFormat = "V:[pageControl]-0-|"
            hFormat = "H:|[pageControl]|"
            
        case .bottomRight:
            vFormat = "V:[pageControl]-0-|"
            hFormat = "H:[pageControl]-|"
            
        case .custom(let customV, let customH):
            vFormat = customV
            hFormat = customH
        }
        
        let pageControl = UIPageControl()
        pageControl.isUserInteractionEnabled = true
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.numberOfPages = self.itemCount
        pageControl.currentPage = 0
        pageControl.isHidden = self.isHidePageControl
        pageControl.addTarget(self, action: #selector(pageControlClick), for: .valueChanged)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pageControl)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vFormat, options: .directionLeftToRight, metrics: nil, views: ["pageControl": pageControl]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hFormat, options: .directionLeftToRight, metrics: nil, views: ["pageControl": pageControl]))
        
        self.pageControl = pageControl
    }
    
    private func restartTimer() {
        weak var weakSelf = self
        if isAutomaticScroll, scrollInterval > 0 {
            self.timer = Timer(timeInterval: scrollInterval, repeats: true, block: { (timer) in
                weakSelf?.timerAction()
            })
            CFRunLoopAddTimer(CFRunLoopGetCurrent(), self.timer, CFRunLoopMode.commonModes)
        }
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func timerAction() {
        self.currentPgaeIndex = self.pageControl?.currentPage ?? 0
        var nextPageIndex = self.currentPgaeIndex + 1
        
        if self.isEndlessScroll, nextPageIndex == self.itemCount + 1 {
            nextPageIndex = 0
        }
        
        guard nextPageIndex < self.itemCount + 1 else {
            return
        }
        
        self.collectionView?.scrollToItem(at: IndexPath(item: nextPageIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc private func pageControlClick(_ pageControl: UIPageControl) {
        // 滑动时点击pageControl无效
        guard self.collectionView?.isDragging == false else {
            return
        }
        
        self.stopTimer()
        let pageIndex = pageControl.currentPage
        self.collectionView?.scrollToItem(at: IndexPath(item: pageIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - CollectionView Delegate
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var items = self.itemCount
        
        if self.isEndlessScroll, self.itemCount != 1 {
           items += 1
        }
        
        return items
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var index = indexPath.item
        
        if index == self.itemCount {
            index = 0
        }
        
        var cell = self.delegate?.imagePlayer?(imagePlayer: self, cellForItemAt: IndexPath(item: index, section: 0))
        
        if cell == nil {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCellReuseId", for: indexPath) as! RNImageViewPlayerCell
        }
        
        if let defaultCell = cell as? RNImageViewPlayerCell {
            self.delegate?.imagePlayer?(imagePlayer: self, willLoadDefaultCellImageWith: defaultCell.imageView, at: index)
        }
        
        return cell!
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.imagePlayer?(imagePlayer: self, didSelectItemAt: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.bounds.width, height: self.bounds.height)
    }
    
    // MARK: - ScrollView delegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.handlePageControlAndTimerWith(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.handlePageControlAndTimerWith(scrollView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        var index = Int(contentOffsetX/self.bounds.width)
        
        if index == self.itemCount, isEndlessScroll {
           index = 0
        }
        
        self.delegate?.imagePlayer?(imagePlayer: self, didScrollAt: index)
        self.pageControl?.currentPage = index
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer()
    }
    
    private func handlePageControlAndTimerWith(_ scrollView: UIScrollView) {
        var index = Int(scrollView.contentOffset.x/self.bounds.width)
        
        if index == self.itemCount, isEndlessScroll {
            self.scrollToFirstItem()
            index = 0
        }
        
        self.delegate?.imagePlayer?(imagePlayer: self, didScrollAt: index)
        self.pageControl?.currentPage = index
        
        if self.timer == nil {
            self.restartTimer()
        }
    }
    
    private func scrollToFirstItem() {
        self.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
    }
    
}

