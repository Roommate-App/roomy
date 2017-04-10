//
//  TodoAddItemViewController.swift
//  roomy
//
//  Created by Rodrigo Bell on 4/9/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit

class TodoAddItemViewController: UIViewController, UINavigationControllerDelegate {
    
    var todoItem: TodoItem?

    @IBOutlet weak var todoItemTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapAddItem(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "todoListViewController") as? TodoListViewController {
            if !((self.todoItemTextField.text?.isEmpty)!) {
                self.todoItem = TodoItem(name: self.todoItemTextField.text!)
                vc.todoItems.add(self.todoItem!)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

}
