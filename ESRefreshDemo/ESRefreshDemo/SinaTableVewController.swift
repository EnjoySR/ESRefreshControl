//
//  SinaTableVewController.swift
//  ESRefreshDemo
//
//  Created by EnjoySR on 15/11/22.
//  Copyright © 2015年 EnjoySR. All rights reserved.
//

import UIKit

class SinaTableVewController: UITableViewController {

    
    private lazy var dataArray: [String] = ["新浪初始数据2","新浪初始数据1","新浪初始数据0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI(){
        tableView.addSubview(sinaRefreshControl)
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
    }
    
    
    
    // 模拟加载数据
    @objc private func loadData(){
        print("loadData")
        dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
            NSThread.sleepForTimeInterval(2)
            
            // 准备数据
            let temp = ["新浪刷新数据\(self.dataArray.count)"];
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // 添加到集合
                self.dataArray = temp + self.dataArray
                
                self.tableView.reloadData()
                // 结束刷新
                self.sinaRefreshControl.endRefreshing()
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
    
    private lazy var sinaRefreshControl: ESSinaRefreshControl = {
        let refreshControl = ESSinaRefreshControl()
        refreshControl.addTarget(self, action: "loadData", forControlEvents: .ValueChanged)
        return refreshControl
    }()

}
