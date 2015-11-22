//
//  NetEaseTableVewController.swift
//  ESRefreshDemo
//
//  Created by EnjoySR on 15/11/22.
//  Copyright © 2015年 EnjoySR. All rights reserved.
//

import UIKit

class NetEaseTableVewController: UITableViewController {
    
    private lazy var dataArray: [String] = ["网易初始数据2","网易初始数据1","网易初始数据0"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI(){
        self.refreshControl = netEaseRefreshControl
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
    }

    // 模拟加载数据
    @objc private func loadData(){
        print("loadData")
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            NSThread.sleepForTimeInterval(2)
            // 准备数据
            let temp = ["网易刷新数据\(self.dataArray.count)"];
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // 添加到集合
                self.dataArray = temp + self.dataArray
                
                self.tableView.reloadData()
                // 结束刷新
                self.netEaseRefreshControl.endRefreshing()
            })
        }
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]
        return cell
    }
    
    // MARK: - 懒加载控件
    
    private lazy var netEaseRefreshControl: ESNetEaseRefreshControl = {
        let refreshControl = ESNetEaseRefreshControl()
        refreshControl.addTarget(self, action: "loadData", forControlEvents: .ValueChanged)
        return refreshControl
    }()
}
