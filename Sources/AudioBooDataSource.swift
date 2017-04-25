import SwiftyJSON
import WebAPI
import TVSetKit
import Wrap

class AudioBooDataSource: DataSource {
  let service = AudioBooService.shared

  func load(_ requestType: String, params: RequestParams, pageSize: Int, currentPage: Int, convert: Bool=true) throws -> [Any] {
    var result: [Any] = []

    let selectedItem = params.selectedItem

    var request = requestType

    if selectedItem?.type == "book" {
      request = "Tracks"
    }

//    switch request {
//      case "Bookmarks":
//        if let bookmarks = params.bookmarks {
//          bookmarks.load()
//          result = bookmarks.getBookmarks(pageSize: pageSize, page: currentPage)
//        }
//
//      case "History":
//        if let history = params.history {
//          history.load()
//          result = history.getHistoryItems(pageSize: pageSize, page: currentPage)
//        }
//
//      case "Author":
//        let path = selectedItem!.id
//
//        result = try service.getBooks(path: path!, page: currentPage)["movies"] as! [Any]
//
//      case "Performer":
//        let path = selectedItem!.id
//
//        result = try service.getBooks(path: path!, page: currentPage)["movies"] as! [Any]
//
//      case "Genre Books":
//        let path = selectedItem!.id
//
//        result = try service.getBooks(path: path!, page: currentPage)["movies"] as! [Any]
//
//      case "New Books":
//        result = try service.getNewBooks(page: currentPage)["movies"] as! [Any]
//
//      case "Best Books":
//        var period = "all"
//
//        if selectedItem!.name == "By Month" {
//          period = "30"
//        }
//        else if selectedItem!.name == "By Week" {
//          period = "7"
//        }
//
//        result = try service.getBestBooks(period: period, page: currentPage)["movies"] as! [Any]
//
//      case "All Authors":
//        result = try service.getAuthors(page: currentPage)["movies"] as! [Any]
//
//      case "Authors Letters":
//        let letters = getLetters(AudioBooService.Authors)
//
//        var list = [Any]()
//
//        list.append(["name": "Все"])
//
//        for letter in letters {
//          list.append(["name": letter])
//        }
//
//        result = list
//
//      case "Authors Letter Groups":
//        if let letter = params.identifier {
//          var letterGroups = [Any]()
//
//          for author in AudioBooService.Authors {
//            let groupName = author.key
//            let group = author.value
//
//            if groupName[groupName.startIndex] == letter[groupName.startIndex] {
//              var newGroup: [Any] = []
//
//              for el in group {
//                newGroup.append(["id": el.id, "name": el.name])
//              }
//
//              letterGroups.append(["name": groupName, "items": newGroup])
//            }
//          }
//
//          result = letterGroups
//        }
//
//      case "Performers Letters":
//        let letters = getLetters(AudioBooService.Performers)
//
//        var list = [Any]()
//
//        list.append(["name": "Все"])
//
//        for letter in letters {
//          list.append(["name": letter])
//        }
//
//        result = list
//
//      case "Performers Letter Groups":
//        if let letter = params.identifier {
//          var letterGroups = [Any]()
//
//          for performer in AudioBooService.Performers {
//            let groupName = performer.key
//            let group = performer.value
//
//            if groupName[groupName.startIndex] == letter[groupName.startIndex] {
//              var newGroup: [Any] = []
//
//              for el in group {
//                newGroup.append(["id": el.id, "name": el.name])
//              }
//
//              letterGroups.append(["name": groupName, "items": newGroup])
//            }
//          }
//
//          result = letterGroups
//        }
//
//      case "Group Authors":
//        result = (selectedItem as! AudioBooMediaItem).items
//
//      case "All Performers":
//        result = try service.getPerformers(page: currentPage)["movies"] as! [Any]
//
//      case "Group Performers":
//        result = (selectedItem as! AudioBooMediaItem).items
//
//      case "Genres":
//        result = try service.getGenres(page: currentPage)["movies"] as! [Any]
//
//      case "Tracks":
//        let url = selectedItem!.id!
//
//        result = try service.getAudioTracks(url)
//
//      case "Search":
//        if let identifier = params.identifier {
//          if !identifier.isEmpty {
//            result = try service.search(identifier, page: currentPage)["movies"] as! [Any]
//          }
//          else {
//            result = []
//          }
//        }
//
//      default:
//        result = []
//    }

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
