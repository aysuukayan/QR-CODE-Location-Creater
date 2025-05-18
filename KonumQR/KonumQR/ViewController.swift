import UIKit
import CoreImage.CIFilterBuiltins

struct IPGeoLocation: Decodable {
    let city: String
    let country: String
    let loc: String  // Örn: "41.0082,28.9784"

    var latitude: Double {
        let components = loc.split(separator: ",")
        return Double(components.first ?? "0") ?? 0
    }

    var longitude: Double {
        let components = loc.split(separator: ",")
        return Double(components.last ?? "0") ?? 0
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var showLocationButton: UIButton!

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showLocationTapped(_ sender: UIButton) {
        fetchIPLocation()
    }

    func fetchIPLocation() {
        let apiKey = "236a00365278c8"
        guard let url = URL(string: "https://ipinfo.io/json?token=\(apiKey)") else {
            print("Geçersiz URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("API hatası: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(IPGeoLocation.self, from: data)
                DispatchQueue.main.async {
                    let locationString = "https://www.google.com/maps?q=\(decoded.latitude),\(decoded.longitude)"
                    self.generateQRCode(from: locationString)
                }
            } catch {
                print("Veri decode edilemedi: \(error.localizedDescription)")
            }
        }.resume()
    }

    func generateQRCode(from string: String) {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                qrImageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
}
