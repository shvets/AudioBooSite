import UIKit
import SwiftyJSON
import SwiftSoup
import WebAPI
import TVSetKit

class AuthorsLetterGroupsTableViewController: BaseTableViewController {
  static let SegueIdentifier = "Authors Letter Groups"

  override open var CellIdentifier: String { return "AuthorsLetterGroupTableCell" }
  override open var BundleId: String { return AudioBooServiceAdapter.BundleId }

  var letter: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

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

            adapter.requestType = "Group Authors"
            adapter.selectedItem = getItem(for: view)
            destination.adapter = adapter
          }

        default: break
      }
    }
  }

}
