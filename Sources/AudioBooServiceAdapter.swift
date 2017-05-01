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
    if let requestType = params["requestType"] as? String, let dataSource = dataSource {
      var newParams = RequestParams()

      newParams["requestType"] = requestType
      newParams["identifier"] = params["requestType"] as? String == "Search" ? params["query"] as? String : params["parentId"] as? String
      newParams["bookmarks"] = bookmarks
      newParams["history"] = history
      newParams["selectedItem"] = params["selectedItem"]
      newParams["pageSize"] = pageLoader.pageSize
      newParams["currentPage"] = pageLoader.currentPage

      dataSource.params = newParams

      return try dataSource.load(convert: true)
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
