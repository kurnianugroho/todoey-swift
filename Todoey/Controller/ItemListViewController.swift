//
//  ItemListViewController.swift
//  Todoey
//
//  Created by Kurnia Adi Nugroho on 26/08/25.
//

import UIKit

class ItemListViewController: UITableViewController {
    @IBOutlet var searchBar: UISearchBar!

    var itemDataSource: ItemDataSource?

    var parentCategory: Category? {
        didSet {
            itemDataSource = ItemDataSource(parentCategory: parentCategory!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
    }

    // MARK: - TableView Datasource Methods

    override func tableView(
        _: UITableView,
        numberOfRowsInSection _: Int,
    ) -> Int {
        itemDataSource!.count()
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath,
    )
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ToDoItemCell",
            for: indexPath,
        )
        let item = itemDataSource!.item(at: indexPath.row)

        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none

        return cell
    }

    override func tableView(
        _: UITableView,
        didSelectRowAt indexPath: IndexPath,
    ) {
        let initialItem = itemDataSource!.item(at: indexPath.row)

        itemDataSource!.update(
            at: indexPath.row,
            title: initialItem.title!,
            isDone: !initialItem.isDone,
        )

        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // MARK: - Add New Items

    @IBAction
    func addButtonPressed(_: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "What needs to be done?",
            message: "",
            preferredStyle: .alert,
        )

        let actionSave = UIAlertAction(
            title: "Add Item",
            style: .default,
        ) { _ in
            if let newItemTitle = alert.textFields?.first?.text {
                self.itemDataSource!.add(newItemTitle)

                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        }

        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(actionSave)
        alert.addAction(actionCancel)

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Write it here..."
        }

        present(alert, animated: true, completion: nil)
    }
}

extension ItemListViewController: UISearchBarDelegate {
    // MARK: - Search Bar

    private func getUpdatedList(_ keyword: String?) {
        if let keyword {
            itemDataSource!.filter(contains: keyword)
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getUpdatedList(searchBar.text)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getUpdatedList(searchText)

        if searchText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
