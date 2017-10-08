import UIKit
import SwiftSoup
import WebAPI
import TVSetKit

class AuthorsLettersTableViewController: AudioBooBaseTableViewController {
  static let SegueIdentifier = "Authors Letters"

  override open var CellIdentifier: String { return "AuthorsLetterTableCell" }
  override open var BundleId: String { return AudioBooServiceAdapter.BundleId }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("Letters")

    tableView?.backgroundView = activityIndicatorView

    adapter.pageLoader.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: AuthorsLetterGroupsTableViewController.SegueIdentifier, sender: view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AuthorsLetterGroupsTableViewController.SegueIdentifier:
          if let destination = segue.destination as? AuthorsLetterGroupsTableViewController,
             let view = sender as? MediaNameTableCell {

            let mediaItem = getItem(for: view) as! MediaItem

            let adapter = AudioBooServiceAdapter(mobile: true)
            adapter.params["requestType"] = "Authors Letter Groups"
            adapter.params["parentId"] = mediaItem.id
            destination.adapter = adapter
          }

        default: break
      }
    }
  }
}
