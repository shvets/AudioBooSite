import UIKit
import Runglish
import TVSetKit

open class SearchTableController: UIViewController, UITextFieldDelegate {
  static let SegueIdentifier = "Search"

  var BundleId: String { return AudioBooServiceAdapter.BundleId }

  @IBOutlet weak var query: UITextField!
  @IBOutlet weak var transcodedQuery: UILabel!
  @IBOutlet weak var useRunglish: UIButton!
  @IBOutlet weak var useRunglishLabel: UILabel!
  @IBOutlet weak var searchButton: UIButton!

  public var adapter: ServiceAdapter!

  var localizer: Localizer!

  var params = [String: Any]()

  let checkedImage = UIImage(named: "ic_check_box")! as UIImage
  let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage

  var isChecked: Bool = false {
    didSet {
      if isChecked == true {
        useRunglish.setImage(checkedImage, for: .normal)
      }
      else {
        useRunglish.setImage(uncheckedImage, for: .normal)
      }
    }
  }

  override open func viewDidLoad() {
    super.viewDidLoad()

    localizer = Localizer(BundleId)

    isChecked = true

    title = localizer.localize("Search")

    useRunglishLabel.text = localizer.localize(useRunglishLabel.text!)
    searchButton.setTitle(localizer.localize(searchButton.title(for: .normal)!), for: .normal)

    searchButton.addTarget(self, action: #selector(self.search(_:)), for: .touchUpInside)

    if let placeholder = query.placeholder {
      query.placeholder = localizer.localize(placeholder)
    }

    query.addTarget(self, action: #selector(self.textFieldModified(textField:)), for: .editingChanged)

    query.delegate = self

    useRunglish.addTarget(self, action: #selector(self.onUseRunglish), for: .touchUpInside)
  }

  func textFieldModified(textField: UITextField) {
    if isChecked {
      let transcoded = LatToRusConverter().transliterate(query.text!)

      transcodedQuery.text = transcoded
    }
    else {
      transcodedQuery.text = ""
    }
  }

  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    query.resignFirstResponder()

    return true;
  }

  func search(_ sender: UIButton) {
    performSegue(withIdentifier: MediaItemsController.SegueIdentifier, sender: view)
  }

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case MediaItemsController.SegueIdentifier:
        if let destination = segue.destination.getActionController() as? MediaItemsController {
          if isChecked {
            let transcoded = LatToRusConverter().transliterate(query.text!)

            adapter.params["query"] = transcoded
            transcodedQuery.text = transcoded
          }
          else {
            adapter.params["query"] = query.text
          }

          destination.adapter = adapter
        }

      default: break
      }
    }
  }

  @IBAction func onUseRunglish(_ sender: UIButton) {
    if isChecked {
      transcodedQuery.text = ""
    }

    isChecked = !isChecked
  }
}
