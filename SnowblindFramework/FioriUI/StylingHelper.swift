import UIKit
import SAPFiori

public class StylingHelper: NSObject {
    @objc
    public static func applySDKTheme(file: String) {
        do {
            let fileURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(file)
            NUISettings.loadStylesheetByURL(url: fileURL)
        } catch {
            print(error)
        }
    }
}
