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

    fileprivate var options: [T]
    fileprivate var selected: [T] {
        didSet {
            selectionAction?(self, selected)
        }
    }
    fileprivate var allowsMultiSelect: Bool
    
    fileprivate var selectionAction: ((_ sender: StaticSelectionViewController<T>, _ selected: [T])->())?
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    convenience init(options: [T], selected: T, selectionAction: ((_ sender: StaticSelectionViewController<T>, _ selected: [T])->())? = nil) {
        self.init(options: options, selectedOptions: [selected], allowsMultiSelect: false, selectionAction: selectionAction)
    }
    
    init(options: [T], selectedOptions: [T], allowsMultiSelect: Bool = true, selectionAction: ((_ sender: StaticSelectionViewController<T>, _ selected: [T])->())? = nil) {
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
        
        tableView.register(UINib(nibName: "StaticCell", bundle: nil), forCellReuseIdentifier: "StaticCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StaticCell", for: indexPath)
        let option = options[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = option.cellTitle
        
        if selected.contains(option) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option = options[(indexPath as NSIndexPath).row]
        
        let cell = tableView.cellForRow(at: indexPath)
        if allowsMultiSelect {
            if let index = selected.index(of: option) {
                // Then we are removing that option
                cell?.accessoryType = .none
                selected.remove(at: index)
                
            } else {
                cell?.accessoryType = .checkmark
                selected.append(option)
            }
        } else {
            //deselect the other one if there is one
            selected.forEach({ (selection) in
                if let index = options.index(of: selection), let oldCell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                    oldCell.accessoryType = .none
                }
            })
            
            cell?.accessoryType = .checkmark
            selected = [option]
        }
    }
    
}
