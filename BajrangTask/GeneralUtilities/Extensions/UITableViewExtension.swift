//
//  UITableViewExtension.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 28/11/24.
//

import UIKit

extension UITableView {
    
    /**
     Registers a cell with the table view.
     Depends on the assumption that the cell's reuse identifier matches its class name.
     If a nib is found in the main app bundle with a filename matching the cell's class name, that nib is registered with the table view. Otherwise, the cell's class is registered with the table view.
     - parameters:
     - type: The class type of the cell to register.
     */
    func registerCell<T: UITableViewCell>(ofType type: T.Type) {
        let cellName = String(describing: T.self)
        
        if Bundle.main.path(forResource: cellName, ofType: "nib") != nil {
            let nib = UINib(nibName: cellName, bundle: Bundle.main)
            
            register(nib, forCellReuseIdentifier: cellName)
        } else {
            register(T.self, forCellReuseIdentifier: cellName)
        }
    }
    
    
    /**
     Dequeues a cell that has been previously registered for use with the table view.
     Depends on the assumption that the cell's class name and reuse identifier are the same.
     - returns: A UITableViewCell already typed to match the `type` provided to the function.
     */
    func dequeueCell<T: UITableViewCell>() -> T     {
        let cellName = String(describing: T.self)
        
        return dequeueReusableCell(withIdentifier: cellName) as! T
    }
}
