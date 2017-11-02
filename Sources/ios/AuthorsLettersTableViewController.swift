import UIKit
import TVSetKit
import PageLoader

class AuthorsLettersTableViewController: UITableViewController {
  static let SegueIdentifier = "Authors Letters"
  let CellIdentifier = "AuthorsLetterTableCell"

  let localizer = Localizer(AudioBooService.BundleId, bundleClass: AudioBooSite.self)
  
  #if os(iOS)
  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  #endif
  
  let service = AudioBooService()

  let pageLoader = PageLoader()
  
  private var items = Items()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("Letters")

    pageLoader.load = {
      var params = Parameters()
      params["requestType"] = "Authors Letters"
      
      return try self.service.dataSource.load(params: params)
    }
    
    #if os(iOS)
      tableView?.backgroundView = activityIndicatorView
      //pageLoader.spinner = PlainSpinner(activityIndicatorView)
    #endif

    pageLoader.loadData { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.tableView?.reloadData()
      }
    }
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
      performSegue(withIdentifier: AuthorsLetterGroupsTableViewController.SegueIdentifier, sender: view)
    }
  }

  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AuthorsLetterGroupsTableViewController.SegueIdentifier:
          if let destination = segue.destination as? AuthorsLetterGroupsTableViewController,
             let view = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: view) {

            let mediaItem = items.getItem(for: indexPath)

            destination.parentId =  mediaItem.id
          }

        default: break
      }
    }
  }
}
