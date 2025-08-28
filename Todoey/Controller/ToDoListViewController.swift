//
//  ToDoListViewController.swift
//  Todoey
//
//  Created by Kurnia Adi Nugroho on 26/08/25.
//

import UIKit

class ToDoListViewController: UITableViewController {
    @IBOutlet var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self

        ToDoDataSource.configure(storageType: StorageTypeEnum.CORE_DATA)
    }

    // MARK: - TableView Datasource Methods

    override func tableView(
        _: UITableView,
        numberOfRowsInSection _: Int,
    ) -> Int {
        ToDoDataSource.shared.count()
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
        let item = ToDoDataSource.shared.item(at: indexPath.row)

        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none

        return cell
    }

    override func tableView(
        _: UITableView,
        didSelectRowAt indexPath: IndexPath,
    ) {
        let initialItem = ToDoDataSource.shared.item(at: indexPath.row)

        ToDoDataSource.shared.update(
            at: indexPath.row,
            to: initialItem.copyWith(isDone: !initialItem.isDone),
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
            if let newItem = alert.textFields?.first?.text {
                ToDoDataSource.shared.add(ToDoItem(
                    title: newItem,
                    isDone: false,
                ))

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

extension ToDoListViewController: UISearchBarDelegate {
    // MARK: - Search Bar

    private func getUpdatedList(_ keyword: String?) {
        if let keyword {
            ToDoDataSource.shared.filter(contains: keyword)
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
