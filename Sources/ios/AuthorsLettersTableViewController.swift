import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class AuthorsLettersTableViewController: BaseTableViewController {
  static let SegueIdentifier = "Authors Letters"

  override open var CellIdentifier: String { return "AuthorsLetterTableCell" }
  override open var BundleId: String { return AudioBooServiceAdapter.BundleId }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    loadInitialData()
  }

  override open func navigate(from view: UITableViewCell) {
    let mediaItem = getItem(for: view)

    let letter = mediaItem.name

    if letter == "Все" {
      performSegue(withIdentifier: AuthorsTableViewController.SegueIdentifier, sender: view)
    }
    else {
      performSegue(withIdentifier: AuthorsLetterGroupsTableViewController.SegueIdentifier, sender: view)
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AuthorsTableViewController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? AuthorsTableViewController {
            let adapter = AudioBooServiceAdapter(mobile: true)
            adapter.pageLoader.enablePagination()
            adapter.pageLoader.pageSize = 30
            adapter.pageLoader.rowSize = 1

            adapter.requestType = "All Authors"
            destination.adapter = adapter
          }

        case AuthorsLetterGroupsTableViewController.SegueIdentifier:
          if let destination = segue.destination as? AuthorsLetterGroupsTableViewController,
             let view = sender as? MediaNameTableCell {

            let mediaItem = getItem(for: view)

            let adapter = AudioBooServiceAdapter(mobile: true)
            adapter.requestType = "Authors Letter Groups"
            adapter.parentId = mediaItem.name
            destination.adapter = adapter

            //destination.letter = mediaItem.name
          }

        default: break
      }
    }
  }
}
