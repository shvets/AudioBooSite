import TVSetKit
import AudioPlayer

open class AudioBooMediaItemsController: MediaItemsController {
  override open func navigate(from view: UICollectionViewCell, playImmediately: Bool=false) {
    if let indexPath = collectionView?.indexPath(for: view),
      let mediaItem = items.getItem(for: indexPath) as? AudioBooMediaItem {

      if mediaItem.hasMultipleVersions() {
        performSegue(withIdentifier: AudioVersionsController.SegueIdentifier, sender: view)
      }
      else {
        performSegue(withIdentifier: AudioItemsController.SegueIdentifier, sender: view)
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
            
            destination.loadAudioVersions = {
              var items: [AudioItem] = []
              
              var params = Parameters()

              params["pageSize"] = self.pageLoader.pageSize
              params["currentPage"] = self.pageLoader.currentPage
              params["requestType"] = "Versions"
              params["selectedItem"] = mediaItem

              if let mediaItems = try self.dataSource?.loadAndWait(params: params) {
                for mediaItem in mediaItems as! [MediaItem] {
                  let item = mediaItem
                  
                  items.append(AudioItem(name: item.name!, id: item.id!))
                }
              }
              
              return items
            }
            
            destination.loadAudioItems = {
              var items: [AudioItem] = []
              
              var params = Parameters()
              
              params["requestType"] = "Tracks"
              params["selectedItem"] = mediaItem
              params["version"] = destination.version

              if let mediaItems = try self.dataSource?.loadAndWait(params: params) as? [MediaItem] {
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
            
            if let requestType = params["requestType"] as? String,
               requestType != "History" {
              historyManager?.addHistoryItem(mediaItem)
            }
            
            destination.loadAudioItems = {
              var items: [AudioItem] = []
              
              var params = Parameters()
              
              params["requestType"] = "Tracks"
              params["selectedItem"] = mediaItem

              if let mediaItems = try self.dataSource?.loadAndWait(params: params) as? [MediaItem] {
                for mediaItem in mediaItems {
                  let item = mediaItem
                    
                  items.append(AudioItem(name: item.name!, id: item.id!))
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

