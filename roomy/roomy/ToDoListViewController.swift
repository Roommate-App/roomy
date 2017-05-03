//
//  TodoListViewController.swift
//  roomy
//
//  Created by Rodrigo Bell on 4/9/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import ParseLiveQuery



// TODO: Update te logic so that the creating of a todo list item happens here to trigger the live query

class TodoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkboxView: UIView!
    
    var todoItems = [TodoItem]()
    var newTodoItem: TodoItem?
    private var subscription1: Subscription<TodoItem>!
    private var subscription2: Subscription<TodoItem>!
    private var subscription3: Subscription<TodoItem>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        let todoItemQuery = getTodosQuery()
        
        
        subscription1 = ParseLiveQuery.Client.shared
            .subscribe(todoItemQuery)
            .handle(Event.updated)  { query, todoItem in
                self.todoItems.removeAll()
                
                self.loadTodos(query: todoItemQuery)
                self.tableView.reloadData()
        }
        
        subscription2 = ParseLiveQuery.Client.shared
            .subscribe(todoItemQuery)
            .handle(Event.deleted)  { _, _ in
                self.todoItems.removeAll()
                
                self.loadTodos(query: todoItemQuery)
                self.tableView.reloadData()
        }

        // Sometimes adds multiples. Maybe Parse bug?
        // Adds multiples if a breakpoint is placed inside the closure thingy.
        subscription3 = ParseLiveQuery.Client.shared
            .subscribe(todoItemQuery)
            .handle(Event.created)  { query, todoItem in
                self.todoItems.removeAll()
                
                self.loadTodos(query: todoItemQuery)
                self.tableView.reloadData()
        }
        
        
    }
    
    func getTodosQuery() -> PFQuery<TodoItem> {
        let query : PFQuery<TodoItem> = PFQuery(className: "TodoItem")
        
        
        query.whereKey("houseID", equalTo: House._currentHouse!)
        
        query.order(byDescending: "createdAt")
        query.limit = 50
        
        return query
    }
    
    private func loadTodos(query: PFQuery<TodoItem>) {
        
        
        
        query.findObjectsInBackground { parseTodos, error in
            if let parseTodos = parseTodos {
                self.add(todoItems: parseTodos)
                self.tableView.reloadData()
            } else {
                print("Error")
            }
        }
    }
    
    private func add(todoItems: [TodoItem] ) {
        
        for todoItem in todoItems {
            self.todoItems.append(todoItem)
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        todoItems.removeAll()
        
        
        let todoItemQuery = getTodosQuery()
//
//        
//        subscription = ParseLiveQuery.Client.shared
//            .subscribe(todoItemQuery)
//            .handle(Event.updated)  { query, todoItem in
//                self.todoItems.removeAll()
//                
//                self.loadTodos(query: todoItemQuery)
//                self.tableView.reloadData()
//        }
//        
//        subscription = ParseLiveQuery.Client.shared
//            .subscribe(todoItemQuery)
//            .handle(Event.updated)  { query, todoItem in
//                self.todoItems.removeAll()
//                
//                self.loadTodos(query: todoItemQuery)
//                self.tableView.reloadData()
//        }
        loadTodos(query: todoItemQuery)
        tableView.reloadData()
        print("")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todo-item-cell")! as UITableViewCell
        
        let todoitem: TodoItem = self.todoItems[indexPath.row]
        
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
        let tappedItem: TodoItem = self.todoItems[indexPath.row]
        tappedItem.completed = !tappedItem.completed
        
        tappedItem.saveInBackground { (success: Bool, error: Error?) in
            if success {
                print("Update checked")
            } else {
                print("There was an error")
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let todoItemToDelete = todoItems[indexPath.row]
            
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            todoItemToDelete.deleteInBackground(block: { (success: Bool, error: Error?) in
                if success {
                    print("Deleted bro")
                } else {
                    print("There was an error")
                }
            })
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
