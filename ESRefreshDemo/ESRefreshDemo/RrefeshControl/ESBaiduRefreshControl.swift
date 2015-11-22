//
//  BaiduRefreshControl.swift
//  ESRefreshDemo
//
//  Created by EnjoySR on 15/11/22.
//  Copyright © 2015年 EnjoySR. All rights reserved.
//

import UIKit

// 背景 View 的最大高度
private let BaiduBgViewMaxHeight: CGFloat = 105
// 刷新状态临界点的值
private let BaiduRefreshStateHeight: CGFloat = 50
// 底部进度条的高度
private let BaiduProgressViewHeight: CGFloat = 4

enum BDRefreshState: Int {
    case Normal = 0 // 默认状态
    case Pulling = 1 // 松手就可以刷新的状态
    case Refreshing = 2 // 正在刷新的状态
}

class ESBaiduRefreshControl: UIControl {

    // 定义 scrollView，用于记录当前控件添加到哪一个 View 上
    var scrollView: UIScrollView?
    
    // 初始的偏移量
    var initContentInsetTop: CGFloat?
    var initContentOffsetY: CGFloat?
    
    
    private var refreshState: BDRefreshState = .Normal {
        didSet{
            switch refreshState {
            case .Pulling:
                if self.refreshView.state != .Pulling {
                    self.refreshView.state = .Pulling
                }
            case .Refreshing:
                if self.refreshView.state != .Refreshing {
                    self.refreshView.state = .Refreshing
                    self.progressView.startAnim()
                    // 调整 contentInsetTop
                    var contentInset = self.scrollView!.contentInset
                    contentInset.top = contentInset.top + BaiduProgressViewHeight
                    self.scrollView?.contentInset = contentInset
                }
            case .Normal:
                if self.refreshView.state != .Normal {
                    self.refreshView.state = .Normal
                    self.progressView.stopAnim()
                    // 调整 contentInsetTop 为初始状态
                    var contentInset = self.scrollView!.contentInset
                    contentInset.top = initContentInsetTop!
                    
                    self.scrollView?.contentInset = contentInset
                }
            }
        }
    }
    
    // MARK: - 提供外界访问方法
    
    func beginRefreshing(){
        self.refreshState = .Refreshing
    }
    
    func endRefreshing() {
        self.refreshState = .Normal
    }

    // MARK: - 初始化控件
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI(){
        backgroundColor = UIColor.clearColor()
        addSubview(refreshView)
        addSubview(progressView)
        
        
        // 添加约束
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BaiduProgressViewHeight))
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: progressView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    // MARK: - 刷新相关逻辑
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 设置
        if self.es_height >= BaiduProgressViewHeight {
            var bgHeight = self.es_height - BaiduProgressViewHeight
            bgHeight = bgHeight > BaiduBgViewMaxHeight ? BaiduBgViewMaxHeight : bgHeight
            
            if self.refreshView.es_width != self.es_width || self.refreshView.es_height != bgHeight {
                self.refreshView.es_size = CGSizeMake(self.es_width, bgHeight)
            }
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if let superView = newSuperview as? UIScrollView where superView.isKindOfClass(UIScrollView.self) {
            superView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
            self.scrollView = superView
            self.es_width = superView.es_width;
        }
    }
    
    deinit{
        // 移除监听
        if let scrollView = self.scrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    
    /// 监听 scrollView 滚动的方法
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        // 取到顶部增加的可滑动的距离
        let contentInsetTop = self.scrollView!.contentInset.top
        // 取到当前 scrollView 的偏移 Y
        let contentOffsetY = self.scrollView!.contentOffset.y
        
        let subResult = abs(Int32(contentInsetTop)) - abs(Int32(contentOffsetY)) + (self.refreshView.state == .Refreshing ? Int32(-BaiduProgressViewHeight) : 0 )
        if subResult >= 0 {
            self.es_height = 0
            // 如果顶部可以滑动距离与 当前偏移的y一样，并且当前状态不是刷新状态
            if subResult == 0 && self.refreshView.state != .Refreshing {
                initContentInsetTop = contentInsetTop
                initContentOffsetY = contentOffsetY
            }
        }else{
            self.es_y = -CGFloat(abs(Int32(subResult)))
            self.es_height = CGFloat(abs(Int32(subResult)))
        }
        
        guard let scroll = self.scrollView else {
            return
        }
        
        // 如果当前控件高度小于5并且当前状态不是刷新状态，就重置刷新状态
        if self.es_height <= BaiduProgressViewHeight && self.refreshView.state != .Refreshing {
            self.refreshView.state = .Normal
        }
        
        // 如果是拖动状态下
        if scroll.dragging {
            if self.refreshView.es_height > BaiduRefreshStateHeight && self.refreshView.state == .Normal {
                self.refreshState = .Pulling
            }else if refreshView.es_height <= BaiduRefreshStateHeight && self.refreshView.state == .Pulling {
                self.refreshState = .Normal
            }
        }else{
            
            if self.refreshView.state == .Pulling {
                // 刷新
                self.refreshView.state = .Refreshing
                progressView.startAnim()
                self.sendActionsForControlEvents(.ValueChanged)
            }else if self.refreshView.state == .Refreshing {
                // 当松开手滚动到只显示进入条的时候，设置可以多滑动的距离
                if CGFloat(subResult) == -BaiduProgressViewHeight * 2 && self.scrollView!.contentInset.top == initContentInsetTop {
                    var contentInset = self.scrollView!.contentInset
                    contentInset.top = contentInset.top + BaiduProgressViewHeight
                    self.scrollView?.contentInset = contentInset
                }
            }
        }
    }
    
    
    // MARK: - 懒加载控件
    
    private lazy var refreshView: BaiduRefreshView = {
        let view = BaiduRefreshView()
        view.backgroundColor = self.backgroundColor
        return view
    }()
    
    // 进度
    private lazy var progressView: BaiduPullProgerssView = {
        let view = BaiduPullProgerssView()
        view.backgroundColor = UIColor(red: 249/255, green: 141/255, blue: 162/255, alpha: 1)
        return view
    }()

}

// MARK: - 刷新 View
private class BaiduRefreshView: UIView {
    
    
    private var centerPoint: CGPoint?
    private var radius: CGFloat?
    private var startAngle: CGFloat?
    private var endAngle: CGFloat?
    
    private var state: BDRefreshState = .Normal {
        didSet{
            switch state {
            case .Pulling:
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.pullForkImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                })
            case .Refreshing:
                print("正在刷新状态")
            case .Normal:
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.pullForkImage.transform = CGAffineTransformIdentity
                })
            }
        }
    }
    
    // MARK: - View 显示处理
    private override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if self.centerPoint == nil {
            return
        }
        
        UIColor.redColor().set()
        let path = UIBezierPath()
        path.lineWidth = 0.5;
        path.addArcWithCenter(self.centerPoint!, radius: self.radius!, startAngle: startAngle!, endAngle: endAngle!, clockwise: false)
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(self.es_width, 0))
        path.fill()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        
        // 添加子控件
        addSubview(pullForkImage)
        addSubview(pullTextImage)
        
        // 添加约束
        pullForkImage.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: pullForkImage, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: pullForkImage, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -10))
        
        pullTextImage.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: pullTextImage, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: pullTextImage, attribute: .Bottom, relatedBy: .Equal, toItem: pullForkImage, attribute: .Top, multiplier: 1, constant: -10))
    }
    
    private override func layoutSubviews() {
        super.layoutSubviews()
        calc()
        setNeedsDisplay()
    }
    
    
    // MARK: - 计算画弧线相关逻辑
    
    /// 计算画弧线所需要的一系列数据，此处为关键逻辑
    private func calc() {
        let a = self.es_height
        if a == 0 {
            return
        }
        let b = self.es_width * 0.5
        
        // 计算 开始/结束 角度
        startAngle = -(CGFloat(M_PI) - atan(a / b))
        endAngle = CGFloat(M_PI) - startAngle!
        
        let alpha = M_PI / 2 - Double(atan(a / b))
        let halfC = sqrt(a * a + b * b) / 2
        
        // 计算圆弧半径
        let result = halfC / CGFloat(cos(alpha))
        centerPoint = CGPointMake(self.es_width * 0.5, self.es_height - result)
        radius = result;
    }
    
    // MARK: - 懒加载控件
    private lazy var pullForkImage: UIImageView = UIImageView(image: UIImage(named: "pull_fork"))
    private lazy var pullTextImage: UIImageView = UIImageView(image: UIImage(named: "pull_text"))
    
}

// MARK: - 进度条 View
private class BaiduPullProgerssView: UIView {
    
    // MARK: - 控件初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI(){
        self.hidden = true
        self.addSubview(progressImage)
        
        
        // 添加约束
        progressImage.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: progressImage, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100))
        addConstraint(NSLayoutConstraint(item: progressImage, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: progressImage, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: -100))
        addConstraint(NSLayoutConstraint(item: progressImage, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
    }
    
    // MARK: - 动画执行
    
    private func startAnim(){
        self.hidden = false
        // y 值更改动画
        let transAnim = CABasicAnimation(keyPath: "transform.translation.x")
        transAnim.fromValue = 0
        transAnim.toValue = UIScreen.mainScreen().bounds.size.width
        transAnim.repeatCount = MAXFLOAT
        transAnim.duration = 2
        
        progressImage.layer.addAnimation(transAnim, forKey: nil)
    }
    
    private func stopAnim(){
        self.hidden = true
        progressImage.layer.removeAllAnimations()
    }
    
    // MARK: - 懒加载控件
    
    // 进度
    private lazy var progressImage: UIImageView = UIImageView(image: UIImage(named: "pull_progress"))
}

