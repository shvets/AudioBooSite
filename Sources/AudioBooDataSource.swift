import WebAPI
import TVSetKit
import AudioPlayer

class AudioBooDataSource: DataSource {
  let service = AudioBooService.shared

  override open func load(params: Parameters) throws -> [Any] {
    var result: [Any] = []
    var tracks = false

    let selectedItem = params["selectedItem"] as? Item

    let request = params["requestType"] as! String
    //let pageSize = params["pageSize"] as? Int
    let currentPage = params["currentPage"] as? Int

    switch request {
    case "Bookmarks":
      if let bookmarks = params["bookmarks"] as? Bookmarks {
        bookmarks.load()
        result = bookmarks.getBookmarks(pageSize: 60, page: currentPage!)
      }

    case "History":
      if let history = params["history"] as? History {
        history.load()
        result = history.getHistoryItems(pageSize: 60, page: currentPage!)
      }

    case "Authors Letters":
      result = try service.getLetters()

    case "Authors Letter Groups":
      if let path = params["parentId"] as? String {
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
      if let selectedItem = selectedItem as? AudioBooMediaItem {
        result = selectedItem.items
      }

    case "Versions":
      if let selectedItem = selectedItem {
        let path = selectedItem.id

        let playlistUrls = try service.getPlaylistUrls(path!)

        var list = [[String: String]]()

        for (index, url) in playlistUrls.enumerated() {
          list.append(["name": "Version \(index+1)", "id": url])
        }

        result = list
      }

    case "Author":
      if let selectedItem = selectedItem {
        result = try service.getBooks(selectedItem.id!)
      }

    case "Tracks":
      if let selectedItem = selectedItem {
        let version = params["version"] as? Int ?? 0
        let playlistUrls = try service.getPlaylistUrls(selectedItem.id!)

        if playlistUrls.count > version {
          let url = playlistUrls[version]

          tracks = true

          result = try service.getAudioTracks(url)
        }
      }

    case "Search":
      if let query = params["query"] as? String {
        if !query.isEmpty {
          result = try service.search(query, page: currentPage!)
        }
        else {
          result = []
        }
      }

    default:
      result = []
    }

    let convert = params["convert"] as? Bool ?? true

    if convert || tracks {
      return convertToMediaItems(result)
    }
    else {
        return result 
    }
  }

  func convertToMediaItems(_ items: Any) -> [Any] {
    var newItems = [Any]()

    if let tracks = items as? [AudioBooAPI.BooTrack] {
      for track in tracks {
        let item = AudioItem(name: track.title + ".mp3", id: track.url)

        newItems += [item]
      }
    }
    else if let items = items as? [[String: Any]] {
      for item in items {
        let movie = AudioBooMediaItem(data: ["name": ""])

        if let dict = item as? [String: String] {
          movie.name = dict["name"]
          movie.id = dict["id"]
          movie.description = dict["description"]
          movie.thumb = dict["thumb"]
          movie.type = dict["type"]
        }
        else {
          movie.name = item["name"] as? String

          if let array = item["items"] as? [[String: String]] {
            var newArray = [AudioBooAPI.PersonName]()

            for elem in array {
              let newElem = AudioBooAPI.PersonName(name: elem["name"]!, id: elem["id"]!)

              newArray.append(newElem)
            }

            movie.items = newArray
          }
        }

        newItems += [movie]
      }
    }
    else if let items = items as? [AudioBooAPI.PersonName] {
      for item in items {
        let movie = AudioBooMediaItem(data: ["name": ""])

        movie.name = item.name
        movie.id = item.id

        newItems += [movie]
      }
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
