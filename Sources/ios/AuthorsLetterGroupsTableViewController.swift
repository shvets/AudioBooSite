import UIKit
import SwiftSoup
import WebAPI
import TVSetKit

class AuthorsLetterGroupsTableViewController: AudioBooBaseTableViewController {
  static let SegueIdentifier = "Authors Letter Groups"

  override open var CellIdentifier: String { return "AuthorsLetterGroupTableCell" }
  override open var BundleId: String { return AudioBooServiceAdapter.BundleId }

  var letter: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("Range")

    tableView?.backgroundView = activityIndicatorView

    adapter.pageLoader.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: AuthorsTableViewController.SegueIdentifier, sender: view)
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AuthorsTableViewController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? AuthorsTableViewController,
             let view = sender as? MediaNameTableCell {

            let adapter = AudioBooServiceAdapter(mobile: true)

            adapter.params["requestType"] = "Authors"
            adapter.params["selectedItem"] = getItem(for: view)
            destination.adapter = adapter
          }

        default: break
      }
    }
  }

}
