//
//  NetEaseRefreshControl.swift
//  ESRefreshDemo
//
//  Created by EnjoySR on 15/11/22.
//  Copyright © 2015年 EnjoySR. All rights reserved.
//

import UIKit


/// 刷新控件的高度
private let NetEaseRefreshViewHeight: CGFloat = 60

class ESNetEaseRefreshControl: UIRefreshControl {

    // 定义 scrollView，用于记录当前控件添加到哪一个 View 上
    var scrollView: UIScrollView?
    
    
    // MARK: - 提供外界访问方法
    
    override func beginRefreshing(){
        super.beginRefreshing()
        refreshView.startAnimation()
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        refreshView.stopAnimation()
    }
    
    // MARK: - 初始化控件
    
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI(){
        // 隐藏菊花
        tintColor = UIColor.clearColor()
        
        // 添加控件
        addSubview(refreshView)
        
        // 添加约束
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: NetEaseRefreshViewHeight))
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if refreshing {
            refreshView.startAnimation()
        }else{
            refreshView.setRefrehchControlHeight(CGFloat(abs(Int32(frame.origin.y))))
        }
    }
    
    deinit {
        // 删除 KVO 监听方法
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    private lazy var refreshView: NetEaseRefreshView = NetEaseRefreshView()

}

private class NetEaseRefreshView: UIView {
    
    // 记录小红球底部的约束
    private var refreshSphereBottomConstraint: NSLayoutConstraint?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI(){
        
        // 添加子控件
        addSubview(stateLabel)
        addSubview(refreshSphere)
        addSubview(refreshCircle)
        
        // 添加约束
        
        // 刷新状态信息
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: stateLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stateLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -10))
        
        // 刷新小球
        refreshSphere.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: refreshSphere, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshSphere, attribute: .Bottom, relatedBy: .Equal, toItem: stateLabel, attribute: .Top, multiplier: 1, constant: -NetEaseRefreshViewHeight - 5))
        refreshSphereBottomConstraint = self.constraints.last!
        addConstraint(NSLayoutConstraint(item: refreshSphere, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: refreshSphere, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 25))
        
        // 刷新圆圈
        refreshCircle.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: refreshCircle, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50))
        addConstraint(NSLayoutConstraint(item: refreshCircle, attribute: .Height, relatedBy: .Equal, toItem: refreshCircle, attribute: .Width, multiplier: CGFloat(15) / 50, constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshCircle, attribute: .CenterX, relatedBy: .Equal, toItem: refreshSphere, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshCircle, attribute: .CenterY, relatedBy: .Equal, toItem: refreshSphere, attribute: .CenterY, multiplier: 1, constant: 0))
        
    }
    
    // MARK: - 动画相关
    
    /// 播放加载动画
    private func startAnimation() {
        
        // 如果当前是刷新状态
        if refreshCircle.hidden == false {
            return
        }
        refreshCircle.layer.removeAllAnimations()
        refreshCircle.hidden = false
        stateLabel.text = "正在刷新"
        // 保存当前刷新的时间
        
        // 缩放动画
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 0.5
        scaleAnim.toValue = 1
        scaleAnim.repeatCount = MAXFLOAT
        scaleAnim.duration = 0.5
        scaleAnim.autoreverses = true
        
        // y 值更改动画
        let transAnim = CABasicAnimation(keyPath: "transform.translation.y")
        transAnim.fromValue = -8
        transAnim.toValue = 8
        transAnim.repeatCount = MAXFLOAT
        transAnim.duration = 1
        transAnim.autoreverses = true
        
        // 动画组
        let group = CAAnimationGroup()
        group.animations = [scaleAnim, transAnim]
        group.repeatCount = MAXFLOAT
        group.duration = 2
        group.removedOnCompletion = false
        refreshCircle.layer.addAnimation(group, forKey: "group")
    }
    
    private func stopAnimation(){
        stateLabel.text = "下拉刷新"
        refreshCircle.hidden = true
        refreshCircle.layer.removeAllAnimations()
    }
    
    // 通过设置 UIRefreshControl 响应刷新球的位置
    func setRefrehchControlHeight(height: CGFloat) {
        var result = -NetEaseRefreshViewHeight - 5 + height
        result = result > -5 ? -5 : result
        refreshSphereBottomConstraint!.constant = result
        refreshSphere.alpha = height / NetEaseRefreshViewHeight
    }
    
    // MARK: - 懒加载控件
    // 显示刷新状态的 label
    private lazy var stateLabel: UILabel =  {
        let label = UILabel()
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(12)
        label.text = "下拉刷新"
        return label
    }()
    
    // 刷新小红球
    private lazy var refreshSphere: UIImageView = UIImageView(image: UIImage(named: "refresh_sphere"))
    
    // 刷新圆圈
    private lazy var refreshCircle: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "refresh_circle"))
        imageView.hidden = true
        return imageView
    }()
}


