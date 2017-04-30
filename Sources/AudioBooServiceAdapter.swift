import UIKit
import SwiftyJSON
import WebAPI
import TVSetKit

class AudioBooServiceAdapter: ServiceAdapter {
  let service = AudioBooService.shared

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/audioboo-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/audioboo-history.json"

  override open class var StoryboardId: String { return "AudioBoo" }
  override open class var BundleId: String { return "com.rubikon.AudioBooSite" }

  lazy var bookmarks = Bookmarks(bookmarksFileName)
  lazy var history = History(historyFileName)

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

  override func load() throws -> [Any] {
    var params = RequestParams()

    params.identifier = requestType == "Search" ? query : parentId
    params.bookmarks = bookmarks
    params.history = history
    params.selectedItem = selectedItem

    if let requestType = requestType, let dataSource = dataSource {
      return try dataSource.load(requestType, params: params, pageSize: pageLoader.pageSize,
        currentPage: pageLoader.currentPage, convert: true)
    }
    else {
      return []
    }
  }

  override func addBookmark(item: MediaItem) -> Bool {
    return bookmarks.addBookmark(item: item)
  }

  override func removeBookmark(item: MediaItem) -> Bool {
    return bookmarks.removeBookmark(item: item)
  }

  override func addHistoryItem(_ item: MediaItem) {
    history.add(item: item)
  }

}
