import UIKit
import TVSetKit
import PageLoader
import AudioPlayer

open class AudioBooTableViewController: UITableViewController {
  static let SegueIdentifier = "Audio Boo"
  let CellIdentifier = "AudioBooTableCell"

  let localizer = Localizer(AudioBooService.BundleId, bundleClass: AudioBooSite.self)

  let service = AudioBooService()
  let pageLoader = PageLoader()
  private var items = Items()

  override open func viewDidLoad() {
    super.viewDidLoad()

    self.clearsSelectionOnViewWillAppear = false

    title = localizer.localize("AudioBoo")

    pageLoader.loadData(onLoad: loadMainMenu) { result in
      if let items = result as? [Item] {
        self.items.items = items

        self.tableView?.reloadData()
      }
    }
  }

  func loadMainMenu() throws -> [Any] {
    return [
      MediaName(name: "Now Listening", imageName: "Now Listening"),
      MediaName(name: "Bookmarks", imageName: "Star"),
      MediaName(name: "History", imageName: "Bookmark"),
      MediaName(name: "All Books", imageName: "Mark Twain"),
      MediaName(name: "Authors", imageName: "Mark Twain"),
      MediaName(name: "Performers", imageName: "Mark Twain"),
      MediaName(name: "Settings", imageName: "Engineering"),
      MediaName(name: "Search", imageName: "Search")
    ]
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
    if let view = tableView.cellForRow(at: indexPath),
       let indexPath = tableView.indexPath(for: view) {
      let mediaItem = items.getItem(for: indexPath)

      switch mediaItem.name! {
        case "Now Listening":
          performSegue(withIdentifier: "Now Listening", sender: view)

        case "Authors":
          performSegue(withIdentifier: "Authors Letters", sender: view)

        case "Performers":
          performSegue(withIdentifier: "Performers Letters", sender: view)
        
        case "Settings":
          performSegue(withIdentifier: "Settings", sender: view)

        case "Search":
          performSegue(withIdentifier: SearchTableController.SegueIdentifier, sender: view)

        default:
          performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
      }
    }
  }

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case MediaItemsController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? MediaItemsController,
             let view = sender as? MediaNameTableCell,
             let indexPath = tableView.indexPath(for: view) {

            let mediaItem = items.getItem(for: indexPath)

            destination.params["requestType"] = mediaItem.name
            destination.params["parentName"] = localizer.localize(mediaItem.name!)

            destination.configuration = service.getConfiguration()
          }

        case "Now Listening":
          if let destination = segue.destination.getActionController() as? AudioItemsController {
            let configuration = service.getConfiguration()

            let playerSettings = AudioPlayer.readSettings(AudioBooService.audioPlayerPropertiesFileName)
            destination.playerSettings = playerSettings
            
            if let dataSource = configuration["dataSource"] as? DataSource,
              let selectedBookId = playerSettings.items["selectedBookId"],
              let selectedBookName = playerSettings.items["selectedBookName"],
              let selectedBookThumb = playerSettings.items["selectedBookThumb"] {
              destination.selectedBookId = selectedBookId
              destination.selectedBookName = selectedBookName
              destination.selectedBookThumb = selectedBookThumb
              destination.selectedItemId = Int(playerSettings.items["selectedItemId"]!)
              destination.currentSongPosition = Float(playerSettings.items["currentSongPosition"]!)!
              
              destination.loadAudioItems = AudioBooMediaItemsController.loadAudioItems(selectedBookId, dataSource: dataSource)
            }
          }

        case SearchTableController.SegueIdentifier:
          if let destination = segue.destination.getActionController() as? SearchTableController {
            destination.params["requestType"] = "Search"
            destination.params["parentName"] = localizer.localize("Search Results")

            destination.configuration = service.getConfiguration()
          }

        default: break
      }
    }
  }

}
