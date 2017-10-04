import UIKit
import SwiftyJSON
import WebAPI
import TVSetKit

class AudioBooMediaItem: MediaItem {
  let service = AudioBooService.shared

  var items = [JSON]()

  override init(data: JSON) {
    super.init(data: data)

    self.items = []

    let items = data["items"].arrayValue

    for item in items {
      self.items.append(item)
    }
  }
  
  required convenience init(from decoder: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }
  
  override func isContainer() -> Bool {
    return type == "book" || type == "tracks"
  }

  override func isAudioContainer() -> Bool {
    return true
  }

  override func hasMultipleVersions() -> Bool {
    var playlistUrls: [Any] = []

    do {
      playlistUrls = try service.getPlaylistUrls(id!)
    }
    catch {
      print("Error getting urls playlist")
    }

    return playlistUrls.count > 1
  }

}
