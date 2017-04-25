import UIKit
import TVSetKit

class BestBooksTableViewController: BaseTableViewController {
  static let SegueIdentifier = "Best Books"

  override open var CellIdentifier: String { return "BestBookTableCell" }
  override open var BundleId: String { return AudioBooServiceAdapter.BundleId }

  let FiltersMenu = [
    "By Week",
    "By Month",
    "All Time"
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("Best Books")

    for name in FiltersMenu {
      let item = MediaItem(name: name)

      items.append(item)
    }
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

            adapter.requestType = "Best Books"
            adapter.selectedItem = getItem(for: view)

            destination.adapter = adapter
          }

        default: break
      }
    }
  }

}
