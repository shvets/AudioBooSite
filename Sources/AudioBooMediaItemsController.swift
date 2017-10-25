import TVSetKit
import AudioPlayer

open class AudioBooMediaItemsController: MediaItemsController {
  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    if let indexPath = collectionView?.indexPath(for: view),
      let mediaItem = items.getItem(for: indexPath) as? MediaItem {
      
      if mediaItem.isAudioContainer() {
        if mediaItem.hasMultipleVersions() {
          performSegue(withIdentifier: AudioVersionsController.SegueIdentifier, sender: view)
        }
        else {
          performSegue(withIdentifier: AudioItemsController.SegueIdentifier, sender: view)
        }
      }
    }
  }
  
  // MARK: Navigation
  
  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier,
      let selectedCell = sender as? MediaItemCell {
      
      if let indexPath = collectionView?.indexPath(for: selectedCell) {
        let mediaItem = items[indexPath.row] as! MediaItem
        
        switch identifier {
        case AudioVersionsController.SegueIdentifier:
          if let destination = segue.destination as? AudioVersionsController {
            destination.name = mediaItem.name
            destination.thumb = mediaItem.thumb
            destination.id = mediaItem.id
            
            destination.pageLoader.load = {
              var items: [AudioItem] = []
              
              var newParams = Parameters()
              
              //              for (key, value) in self.params {
              //                newParams[key] = value
              //              }
              
              newParams["pageSize"] = self.items.pageLoader.pageSize
              newParams["currentPage"] = self.items.pageLoader.currentPage
              newParams["requestType"] = "Versions"
              newParams["selectedItem"] = mediaItem

              if let data = try self.dataSource?.load(params: newParams),
                let mediaItems = data as? [MediaItem] {
                for mediaItem in mediaItems {
                  let item = mediaItem
                  
                  items.append(AudioItem(name: item.name!, id: item.id!))
                }
              }
              
              return items
            }
            
            destination.audioItemsLoad = {
              var items: [AudioItem] = []
              
              var newParams = Parameters()
              
              for (key, value) in self.params {
                newParams[key] = value
              }
              
              newParams["requestType"] = "Tracks"
              newParams["selectedItem"] = mediaItem
              newParams["version"] = destination.version

              if let data = try self.dataSource?.load(params: newParams),
                let mediaItems = data as? [MediaItem] {
                for mediaItem in mediaItems {
                  let item = mediaItem
                  
                  items.append(AudioItem(name: item.name!, id: item.id!))
                }
              }
              
              return items
            }
          }
          
        case AudioItemsController.SegueIdentifier:
          if let destination = segue.destination as? AudioItemsController {
            destination.name = mediaItem.name
            destination.thumb = mediaItem.thumb
            destination.id = mediaItem.id
            
            if let requestType = params["requestType"] as? String {
              if requestType != "History" {
                historyManager?.addHistoryItem(mediaItem)
              }
            }
            
            destination.pageLoader.load = {
              var items: [AudioItem] = []
              
              var newParams = Parameters()
              
              for (key, value) in self.params {
                newParams[key] = value
              }
              
              newParams["requestType"] = "Tracks"
              newParams["selectedItem"] = mediaItem

              if let data = try self.dataSource?.load(params: newParams) {
                if let mediaItems = data as? [MediaItem] {
                  for mediaItem in mediaItems {
                    let item = mediaItem
                    
                    items.append(AudioItem(name: item.name!, id: item.id!))
                  }
                }
              }
              
              return items
            }
          }
        default:
          super.prepare(for: segue, sender: sender)
        }
      }
    }
  }
  
}

