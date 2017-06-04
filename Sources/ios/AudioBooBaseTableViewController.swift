import TVSetKit

open class AudioBooBaseTableViewController: BaseTableViewController {
  let service = AudioBooService.shared

  override open func viewDidLoad() {
    super.viewDidLoad()

    localizer = Localizer(AudioBooServiceAdapter.BundleId, bundleClass: AudioBooSite.self)
  }

}
