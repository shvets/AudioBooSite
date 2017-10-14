import UIKit
import TVSetKit

class AuthorsLetterGroupsTableViewController: UITableViewController {
  static let SegueIdentifier = "Authors Letter Groups"
  let CellIdentifier = "AuthorsLetterGroupTableCell"

  let localizer = Localizer(AudioBooServiceAdapter.BundleId, bundleClass: AudioBooSite.self)

#if os(iOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
#endif

  var letter: String?

  var parentId: String?
  
  private var items: Items!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("Range")

    items = Items() {
      let adapter = AudioBooServiceAdapter(mobile: true)
      adapter.params["requestType"] = "Authors Letter Groups"
      adapter.params["parentId"] = self.parentId
      
      return try adapter.load()
    }
    
    tableView?.backgroundView = activityIndicatorView
    items.pageLoader.spinner = PlainSpinner(activityIndicatorView)

    items.loadInitialData(tableView)
  }

  // MARK: UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as? MediaNameTableCell {
      let item = items[indexPath.row]

      cell.configureCell(item: item, localizedName: localizer.getLocalizedName(item.name))

      return cell
    }
    else {
      return UITableViewCell()
    }
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let view = tableView.cellForRow(at: indexPath) {
      performSegue(withIdentifier: AuthorsTableViewController.SegueIdentifier, sender: view)
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AuthorsTableViewController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? AuthorsTableViewController,
             let view = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: view) {

            destination.selectedItem = items.getItem(for: indexPath)
          }

        default: break
      }
    }
  }

}
