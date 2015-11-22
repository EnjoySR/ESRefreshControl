//
//  SinaRefreshControl.swift
//  ESRefreshDemo
//
//  Created by EnjoySR on 15/11/22.
//  Copyright © 2015年 EnjoySR. All rights reserved.
//

import UIKit
// 默认高度
private let SinaRefreshControlHeight: CGFloat = 44

enum SinaRefreshState: Int {
    case Normal = 0 // 默认状态
    case Pulling = 1 // 松手就可以刷新的状态
    case Refreshing = 2 // 正在刷新的状态
}

class ESSinaRefreshControl: UIControl {

    // 定义 scrollView，用于记录当前控件添加到哪一个 View 上
    var scrollView: UIScrollView?
    
    // 旧状态
    var oldState: SinaRefreshState?
    
    // 定义当前控件的刷新状态
    var refreshState: SinaRefreshState = .Normal {
        didSet{
            switch refreshState {
            case .Pulling:      // 松手就可以刷新的状态
                self.arrowIcon.transform = CGAffineTransformMakeRotation(-0.01)
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.arrowIcon.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                })
                messageLabel.text = "释放更新"
            case .Normal:       // 置为默认的状态的效果
                self.arrowIcon.transform = CGAffineTransformIdentity
                messageLabel.text = "下拉刷新"
                arrowIcon.hidden = false
                indecator.stopAnimating()
                
                // 如果之前状态是刷新状态，需要递减 contentInset.top
                if oldState == .Refreshing {
                    // 重置contentInsetTop
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        var contentInset = self.scrollView!.contentInset
                        contentInset.top -= self.es_height
                        self.scrollView?.contentInset = contentInset
                    })
                }
                
            case .Refreshing:   // 显示刷新的效果
                // 添加顶部可以多滑动的距离
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    var contentInset = self.scrollView!.contentInset
                    contentInset.top += self.es_height
                    self.scrollView?.contentInset = contentInset
                })
                
                // 隐藏箭头
                arrowIcon.hidden = true
                // 开始菊花转
                indecator.startAnimating()
                // 显示 `加载中…`
                messageLabel.text = "加载中…"
                
                // 调用刷新的方法
                sendActionsForControlEvents(.ValueChanged)
            }
            oldState = refreshState
        }
    }
    
    // MARK: - 提供给外界的方法
    
    /// 结束刷新
    func endRefreshing(){
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
        
        es_height = SinaRefreshControlHeight;
        es_y = -SinaRefreshControlHeight
        
        // 添加控件
        addSubview(arrowIcon)
        addSubview(messageLabel)
        addSubview(indecator)
        
        // 添加约束
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: arrowIcon, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: -30))
        addConstraint(NSLayoutConstraint(item: arrowIcon, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .Leading, relatedBy: .Equal, toItem: arrowIcon, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: arrowIcon, attribute: .CenterY, multiplier: 1, constant: 0))

        indecator.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: indecator, attribute: .CenterX, relatedBy: .Equal, toItem: arrowIcon, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: indecator, attribute: .CenterY, relatedBy: .Equal, toItem: arrowIcon, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    // MARK: - 初始拖动相关逻辑
    
    /// 当前 view 的父视图即将改变的时候会调用，可以在这个方法里面拿到父控件
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        // 如果父控件不为空，并且父控件是UIScrollView
        if let scrollView = newSuperview where scrollView.isKindOfClass(NSClassFromString("UIScrollView")!) {
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
            // 记录当前 scrollView，以便在 `deinit` 方法里面移除监听
            self.scrollView = scrollView as? UIScrollView
            self.es_width = scrollView.es_width
        }
    }
    
    
    /// 当值改变之后回调的方法
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        // 取到顶部增加的可滑动的距离
        let contentInsetTop = self.scrollView!.contentInset.top
        // 取到当前 scrollView 的偏移 Y
        let contentOffsetY = self.scrollView!.contentOffset.y
        
        // 临界值
        let criticalValue = -contentInsetTop - self.es_height
        
        // 在用户拖动的时候去判断临界值
        if scrollView!.dragging {
            if refreshState == .Normal && contentOffsetY < criticalValue {
                // 完全显示出来
                self.refreshState = .Pulling
            }else if refreshState == .Pulling && contentOffsetY >= criticalValue {
                // 没有完全显示出来/没有显示出来
                self.refreshState = .Normal
            }
        }else{
            // 判断如果用户已经松手，并且当前状态是.Pulling，那么进入到 .Refreshing 状态
            if self.refreshState == .Pulling {
                self.refreshState = .Refreshing
            }
        }
    }
    
    deinit{
        // 移除监听
        if let scrollView = self.scrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    // MARK: - 懒加载控件
    // 箭头图标
    private lazy var arrowIcon: UIImageView = UIImageView(image: UIImage(named: "tableview_pull_refresh"))
    // 显示文字的label
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "下拉刷新"
        label.textColor = UIColor.grayColor()
        label.font = UIFont.systemFontOfSize(12)
        return label
        }()
    // 菊花转
    private lazy var indecator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
}
