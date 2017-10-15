import UIKit
import WebAPI
import TVSetKit

class AudioBooServiceAdapter: ServiceAdapter {
  let service = AudioBooService.shared

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/audioboo-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/audioboo-history.json"

  override open class var StoryboardId: String { return "AudioBoo" }
  override open class var BundleId: String { return "com.rubikon.AudioBooSite" }

    lazy var bookmarks = Bookmarks(AudioBooServiceAdapter.bookmarksFileName)
    lazy var history = History(AudioBooServiceAdapter.historyFileName)

  public init(mobile: Bool=false) {
    super.init(dataSource: AudioBooDataSource(), mobile: mobile)

    bookmarks.load()
    history.load()

    pageLoader.load = {
      return try self.load()
    }
  }

  override open func clone() -> ServiceAdapter {
    let cloned = AudioBooServiceAdapter(mobile: mobile!)

    cloned.clear()

    return cloned
  }

  override open func load() throws -> [Any] {
    params["bookmarks"] = bookmarks
    params["history"] = history

    return try super.load()
  }

  override func addBookmark(item: MediaItem) -> Bool {
    return bookmarks.addBookmark(item: item)
  }

  override func removeBookmark(item: MediaItem) -> Bool {
    return bookmarks.removeBookmark(id: item.id!)
  }

  override func addHistoryItem(_ item: MediaItem) {
    history.add(item: item)
  }

  func getConfiguration() -> Configuration {
    var conf = Configuration()

    conf.pageSize = 12
    conf.rowSize = 1

    return conf
  }
}
