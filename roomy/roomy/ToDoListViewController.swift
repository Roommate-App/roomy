//
//  TodoListViewController.swift
//  roomy
//
//  Created by Rodrigo Bell on 4/9/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import ParseLiveQuery

class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkboxView: UIView!
    
    var todoItems: NSMutableArray = []
    private var subscription: Subscription<TodoItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        let todoItemQuery = getTodosQuery()
        subscription = ParseLiveQuery.Client.shared
            .subscribe(todoItemQuery)
            .handle(Event.created)  { query, pfMessage in
                self.tableView.reloadData()
        }
        
    }
    
    func getTodosQuery() -> PFQuery<TodoItem> {
        let query : PFQuery<TodoItem> = PFQuery(className: "TodoItem")
        
        query.whereKey("HouseID", equalTo: House._currentHouse!)
        
        query.order(byDescending: "createdAt")
        query.limit = 50
        
        return query
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todo-item-cell")! as UITableViewCell
        
        let todoitem: TodoItem = self.todoItems.object(at: indexPath.row) as! TodoItem
        
        cell.textLabel?.text = todoitem.itemName as String
        
        if todoitem.completed {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let tappedItem: TodoItem = self.todoItems.object(at: indexPath.row) as! TodoItem
        tappedItem.completed = !tappedItem.completed
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todoItems.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
