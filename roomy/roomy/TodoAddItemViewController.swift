//
//  TodoAddItemViewController.swift
//  roomy
//
//  Created by Rodrigo Bell on 4/9/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse

class TodoAddItemViewController: UIViewController, UINavigationControllerDelegate {
    
    var todoItem: TodoItem?

    @IBOutlet weak var todoItemTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationController?.delegate = self\
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapAddItem(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? TodoListViewController {
            if !((self.todoItemTextField.text?.isEmpty)!) {

                //self.todoItem = TodoItem(name: self.todoItemTextField.text!)
                //vc.todoItems.add(self.todoItem!)

                self.todoItem = TodoItem(name: self.todoItemTextField.text!, house: House._currentHouse!)
                vc.newTodoItem = self.todoItem

                self.todoItem?.saveInBackground(block: { (success, error) in
                    if success {
                        vc.newTodoItem = self.todoItem
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                })
            }
        }
    }

}
