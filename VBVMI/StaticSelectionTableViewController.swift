//
//  StaticSelectionTableViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 3/09/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

protocol StaticSelectable: Equatable {
    
    var cellTitle: String { get }
    
}

class StaticSelectionViewController<T: StaticSelectable>: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var options: [T]
    private var selected: [T] {
        didSet {
            selectionAction?(sender: self, selected: selected)
        }
    }
    private var allowsMultiSelect: Bool
    
    private var selectionAction: ((sender: StaticSelectionViewController<T>, selected: [T])->())?
    
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    convenience init(options: [T], selected: T, selectionAction: ((sender: StaticSelectionViewController<T>, selected: [T])->())? = nil) {
        self.init(options: options, selectedOptions: [selected], allowsMultiSelect: false, selectionAction: selectionAction)
    }
    
    init(options: [T], selectedOptions: [T], allowsMultiSelect: Bool = true, selectionAction: ((sender: StaticSelectionViewController<T>, selected: [T])->())? = nil) {
        self.options = options
        self.selected = selectedOptions
        self.allowsMultiSelect = allowsMultiSelect
        self.selectionAction = selectionAction
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerNib(UINib(nibName: "StaticCell", bundle: nil), forCellReuseIdentifier: "StaticCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StaticCell", forIndexPath: indexPath)
        let option = options[indexPath.row]
        cell.textLabel?.text = option.cellTitle
        
        if selected.contains(option) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let option = options[indexPath.row]
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if allowsMultiSelect {
            if let index = selected.indexOf(option) {
                // Then we are removing that option
                cell?.accessoryType = .None
                selected.removeAtIndex(index)
                
            } else {
                cell?.accessoryType = .Checkmark
                selected.append(option)
            }
        } else {
            //deselect the other one if there is one
            selected.forEach({ (selection) in
                if let index = options.indexOf(selection), let oldCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) {
                    oldCell.accessoryType = .None
                }
            })
            
            cell?.accessoryType = .Checkmark
            selected = [option]
        }
    }
    
}
