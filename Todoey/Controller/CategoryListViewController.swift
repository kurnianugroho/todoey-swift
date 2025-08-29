//
//  CategoryListViewController.swift
//  Todoey
//
//  Created by Kurnia Adi Nugroho on 29/08/25.
//

import UIKit

class CategoryListViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: nil,
            action: nil,
        )
    }

    // MARK: - TableView Datasource Methods

    override func tableView(
        _: UITableView,
        numberOfRowsInSection _: Int,
    ) -> Int {
        CategoryDataSource.shared.count()
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath,
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath,
        )
        let category = CategoryDataSource.shared.item(at: indexPath.row)

        cell.textLabel?.text = category.name
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    // MARK: - Add New Items

    @IBAction func addButtonPressed(_: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "New category to be done?",
            message: "",
            preferredStyle: .alert,
        )

        let actionSave = UIAlertAction(
            title: "Add Item",
            style: .default,
        ) { _ in
            if let newCategoryName = alert.textFields?.first?.text {
                CategoryDataSource.shared.add(named: newCategoryName)

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

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "goToItems" {
            if
                let destinationVC = segue
                    .destination as? ItemListViewController
            {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let category = CategoryDataSource.shared
                        .item(at: indexPath.row)
                    destinationVC.parentCategory = category
                }
            }
        }
    }
}
