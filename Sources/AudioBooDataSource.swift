import SwiftyJSON
import WebAPI
import TVSetKit
import Wrap

class AudioBooDataSource: DataSource {
  let service = AudioBooService.shared

  func load(_ requestType: String, params: RequestParams, pageSize: Int, currentPage: Int, convert: Bool=true) throws -> [Any] {
    var result: [Any] = []

    let selectedItem = params.selectedItem

    let request = requestType

    switch request {
      case "Bookmarks":
        if let bookmarks = params.bookmarks {
          bookmarks.load()
          result = bookmarks.getBookmarks(pageSize: pageSize, page: currentPage)
        }

      case "History":
        if let history = params.history {
          history.load()
          result = history.getHistoryItems(pageSize: pageSize, page: currentPage)
        }

      case "Authors Letters":
         result = try service.getLetters()

      case "Authors Letter Groups":
        if let path = params.identifier {
          let authors = try service.getAuthorsByLetter(path)

          for (key, value) in authors {
            let group = value as! [NameClassifier.Item]

            var newGroup: [[String: String]] = []

            for el in group {
              newGroup.append(["id": el.id, "name": el.name])
            }

            result.append(["name": key, "items": newGroup])
          }
        }

      case "Authors":
        result = (selectedItem as! AudioBooMediaItem).items

      case "Versions":
        let path = selectedItem!.id

        let playlistUrls = try service.getPlaylistUrls(path!)

        var list = [[String: String]]()

        for (index, url) in playlistUrls.enumerated() {
          list.append(["name": "Version \(index+1)", "id": url as! String])
        }

        result = list

      case "Author":
        let path = selectedItem!.id

        result = try service.getBooks(path!)

      case "Tracks":
        let version = params.version ?? 0
        let playlistUrls = try service.getPlaylistUrls(selectedItem!.id!)

        let url = playlistUrls[version] as! String

        result = try service.getAudioTracks(url)

      case "Search":
        if let identifier = params.identifier {
          if !identifier.isEmpty {
            result = try service.search(identifier, page: currentPage)
          }
          else {
            result = []
          }
        }

      default:
        result = []
    }

    if convert {
      return convertToMediaItems(result)
    }
    else {
      return result
    }
  }

  func convertToMediaItems(_ items: [Any]) -> [MediaItem] {
    var newItems = [MediaItem]()

    for item in items {
      var jsonItem = item as? JSON

      if jsonItem == nil {
        jsonItem = JSON(item)
      }

      let movie = AudioBooMediaItem(data: jsonItem!)

      newItems += [movie]
    }

    return newItems
  }

  func getLetters(_ items: [NameClassifier.ItemsGroup]) -> [String] {
    var rletters = [String]()
    var eletters = [String]()

    for item in items {
      let groupName = item.key

      let index = groupName.index(groupName.startIndex, offsetBy: 0)

      let letter = String(groupName[index])

      if (letter >= "a" && letter <= "z") || (letter >= "A" && letter <= "Z") {
        if !eletters.contains(letter) {
          eletters.append(letter)
        }
      }
      else if (letter >= "а" && letter <= "я") || (letter >= "А" && letter <= "Я") {
        if !rletters.contains(letter) {
          rletters.append(letter)
        }
      }
    }

    return rletters + eletters
  }

}
