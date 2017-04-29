import Foundation
import WebAPI

public class AudioBooService {

  static let shared: AudioBooAPI = {
    return AudioBooAPI()
  }()

}
