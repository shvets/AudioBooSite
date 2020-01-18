import UIKit
import MediaApis
import TVSetKit

class AudioBooMediaItem: MediaItem {
  let service = AudioBooService.shared

  var items = [AudioBooAPI.PersonName]()

  required convenience init(from decoder: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }

  func hasMultipleVersions() -> Bool {
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
