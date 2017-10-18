import Foundation
import WebAPI
import TVSetKit

public class AudioBooService {
  static let shared: AudioBooAPI = {
    return AudioBooAPI()
  }()

  static let bookmarksFileName = NSHomeDirectory() + "/Library/Caches/audioboo-bookmarks.json"
  static let historyFileName = NSHomeDirectory() + "/Library/Caches/audioboo-history.json"

  static let StoryboardId = "AudioBoo"
  static let BundleId = "com.rubikon.AudioBooSite"

  lazy var bookmarks = Bookmarks(AudioBooService.bookmarksFileName)
  lazy var history = History(AudioBooService.historyFileName)

  lazy var bookmarksManager = BookmarksManager(bookmarks)
  lazy var historyManager = HistoryManager(history)

  var dataSource = AudioBooDataSource()

  public init() {}

  func getConfiguration() -> [String: Any] {
    return [
      "pageSize": 12,
      "rowSize": 1,
      "mobile": true,
      "bookmarksManager": bookmarksManager,
      "historyManager": historyManager,
      "dataSource": dataSource,
      "storyboardId": AudioBooService.StoryboardId,
      "bundleId": AudioBooService.BundleId
    ]
  }
}
