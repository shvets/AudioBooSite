import MediaApis
import TVSetKit

class AudioBooDataSource: DataSource {
  let service = AudioBooService.shared

  override open func load(params: Parameters) throws -> [Any] {
    var items: [Any] = []

    let selectedItem = params["selectedItem"] as? Item

    let request = params["requestType"] as! String
    let currentPage = params["currentPage"] as? Int ?? 1
    let pageSize = params["pageSize"] as? Int ?? 27

    switch request {
    case "Bookmarks":
      if let bookmarksManager = params["bookmarksManager"] as? BookmarksManager,
         let bookmarks = bookmarksManager.bookmarks {
        let data = bookmarks.getBookmarks(pageSize: pageSize, page: currentPage)

        items = adjustItems(data)
      }

    case "History":
      if let historyManager = params["historyManager"] as? HistoryManager,
         let history = historyManager.history {
        let data = history.getHistoryItems(pageSize: pageSize, page: currentPage)

        items = adjustItems(data)
      }

    case "Authors Letters":
      let result = try service.getLetters()

      items = self.adjustItems(result)

    case "Authors Letter Groups":
      if let letter = params["parentId"] as? String {
        items = adjustItems(try getAuthorsByLetter(letter))
      }

    case "All Books":
      items = adjustItems(try service.getAllBooks(page: currentPage))

    case "Authors":
      if let selectedItem = selectedItem as? AudioBooMediaItem {
        items = adjustItems(selectedItem.items)
      }

    case "Versions":
      if let selectedItem = selectedItem,
        let path = selectedItem.id {

        let playlistUrls = try service.getPlaylistUrls(path)

        var list = [MediaItem]()

        for (index, url) in playlistUrls.enumerated() {
          list.append(MediaItem(name: "Version \(index+1)", id: url))
        }

        items = list
      }

    case "Author":
      if let selectedItem = selectedItem,
        let id = selectedItem.id {
        items = adjustItems(try service.getBooks(id, page: currentPage))
      }

    case "Tracks":
      if let url = params["url"] as? String {
        let playlistUrls = try service.getPlaylistUrls(url)

        let version = params["version"] as? Int ?? 0

        if playlistUrls.count > version {
          let url = playlistUrls[version]

          items = adjustItems(try service.getAudioTracks(url))
        }
        else {
          items = adjustItems(try service.getAudioTracksNew(url))
        }
      }

    case "Search":
      if let query = params["query"] as? String {
        if !query.isEmpty {
           items = adjustItems(try service.search(query, page: currentPage))
        }
      }

    default:
      items = []
    }

    return items
  }

  func adjustItems(_ items: [Any]) -> [Item] {
    var newItems = [Item]()

    if let items = items as? [HistoryItem] {
      newItems = transform(items) { item in
        createHistoryItem(item as! HistoryItem)
      }
    }
    else if let items = items as? [BookmarkItem] {
      newItems = transform(items) { item in
        createBookmarkItem(item as! BookmarkItem)
      }
    }
    else if let items = items as? [AudioBooAPI.PersonName] {
      newItems = transform(items) { item in
        let item = item as! AudioBooAPI.PersonName

        return MediaItem(name: item.name, id: String(describing: item.id))
      }
    }
    else if let items = items as? [AudioBooAPI.BooTrack] {
      newItems = transform(items) { item in
        let track = item as! AudioBooAPI.BooTrack

        return MediaItem(name: track.title + ".mp3", id: String(describing: track.url))
      }
    }
    else if let items = items as? [AudioBooAPI.BooTrack2] {
      newItems = transform(items) { item in
        let track = item as! AudioBooAPI.BooTrack2

        return MediaItem(name: track.title, id: String(describing: track.file))
      }
    }
    else if let items = items as? [[String: Any]] {
      newItems = transform(items) { item in
        createMediaItem(item as! [String: Any])
      }
    }
    else if let items = items as? [Item] {
      newItems = items
    }

    return newItems
  }

  func createHistoryItem(_ item: HistoryItem) -> Item {
    let newItem = AudioBooMediaItem(data: ["name": ""])

    newItem.name = item.item.name
    newItem.id = item.item.id
    newItem.description = item.item.description
    newItem.thumb = item.item.thumb
    newItem.type = item.item.type

    return newItem
  }

  func createBookmarkItem(_ item: BookmarkItem) -> Item {
    let newItem = AudioBooMediaItem(data: ["name": ""])

    newItem.name = item.item.name
    newItem.id = item.item.id
    newItem.description = item.item.description
    newItem.thumb = item.item.thumb
    newItem.type = item.item.type

    return newItem
  }

  func createMediaItem(_ item: [String: Any]) -> Item {
    let newItem = AudioBooMediaItem(data: ["name": ""])

    if let dict = item as? [String: String] {
      newItem.name = dict["name"]
      newItem.id = dict["id"]
      newItem.description = dict["description"]
      newItem.thumb = dict["thumb"]
      newItem.type = dict["type"]
    } else {
      newItem.name = item["name"] as? String

      if let array = item["items"] as? [[String: String]] {
        var newArray = [AudioBooAPI.PersonName]()

        for elem in array {
          let newElem = AudioBooAPI.PersonName(name: elem["name"]!, id: elem["id"]!)

          newArray.append(newElem)
        }

        newItem.items = newArray
      }
    }

    return newItem
  }

  func getAuthorsByLetter(_ letter: String) throws -> [[String: Any]] {
    var data = [[String: Any]]()

    let authors = try service.getAuthorsByLetter(letter)

    for author in authors {
      //if let group = author.value as? [NameClassifier.Item] {
      let group = author.value

      var newGroup: [[String: String]] = []

      for el in group {
        newGroup.append(["id": el.id, "name": el.name])
      }

      data.append(["name": author.key, "items": newGroup])
      //}
    }

    return data
  }

  func getLetters(_ items: [NameClassifier.ItemsGroup]) -> [String] {
    var ruLetters = [String]()
    var enLetters = [String]()

    for item in items {
      let groupName = item.key

      let index = groupName.index(groupName.startIndex, offsetBy: 0)

      let letter = String(groupName[index])

      if (letter >= "a" && letter <= "z") || (letter >= "A" && letter <= "Z") {
        if !enLetters.contains(letter) {
          enLetters.append(letter)
        }
      }
      else if (letter >= "а" && letter <= "я") || (letter >= "А" && letter <= "Я") {
        if !ruLetters.contains(letter) {
          ruLetters.append(letter)
        }
      }
    }

    return ruLetters + enLetters
  }

}
