import Foundation
import WebAPI

public class AudioBooService {

  static let shared: AudioBooAPI = {
    return AudioBooAPI()
  }()

//  static var Authors = shared.getItemsInGroups(Bundle(identifier: AudioBooServiceAdapter.BundleId)!.path(forResource: "authors-in-groups", ofType: "json")!)
//  static var Performers = shared.getItemsInGroups(Bundle(identifier: AudioBooServiceAdapter.BundleId)!.path(forResource: "performers-in-groups", ofType: "json")!)

}
