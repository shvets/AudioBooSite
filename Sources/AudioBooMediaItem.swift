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
  
  override func isContainer() -> Bool {
    return type == "book" || type == "tracks"
  }

  override func isAudioContainer() -> Bool {
    return true
  }

}
