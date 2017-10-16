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

  var bookmarksManager: BookmarksManager?
  var historyManager: HistoryManager?

  public init(mobile: Bool=false) {
    super.init(dataSource: AudioBooDataSource(), mobile: mobile)

    bookmarks.load()
    history.load()

    bookmarksManager = BookmarksManager(bookmarks)
    historyManager = HistoryManager(history)

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

  func getConfiguration() -> [String: Any] {
    return [
      "pageSize": 12,
      "rowSize": 1,
      "bookmarksManager": bookmarksManager as Any,
      "historyManager": historyManager as Any
    ]
  }
}
