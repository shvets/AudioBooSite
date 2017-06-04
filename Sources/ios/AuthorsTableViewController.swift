import UIKit
import TVSetKit

class AuthorsTableViewController: AudioBooBaseTableViewController {
  static let SegueIdentifier = "Authors"

  override open var CellIdentifier: String { return "AuthorTableCell" }
  override open var BundleId: String { return AudioBooServiceAdapter.BundleId }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("Authors")

    tableView?.backgroundView = activityIndicatorView

    adapter.pageLoader.spinner = PlainSpinner(activityIndicatorView)

    loadInitialData()
  }

  override open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell {

            let adapter = AudioBooServiceAdapter(mobile: true)

            adapter.params["requestType"] = "Author"
            adapter.params["selectedItem"] = getItem(for: view)

            destination.adapter = adapter
          }

        default: break
      }
    }
  }

}
