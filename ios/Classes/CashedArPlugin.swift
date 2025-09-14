import Flutter
import UIKit
import QuickLook

@available(iOS 10.0, *)
public class CashedArPlugin: NSObject, FlutterPlugin, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    private var fileURL: URL?
    private var result: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cashed_ar_channel", binaryMessenger: registrar.messenger())
        let instance = CashedArPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showARViewer":
            handleShowARViewer(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleShowARViewer(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let fileName = arguments["fileName"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "fileName is required",
                              details: nil))
            return
        }
        
        self.result = result
        
        if let url = getFileURL(fileName: fileName) {
            showARViewer(url: url)
        } else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                              message: "Could not find AR file: \(fileName)",
                              details: nil))
        }
    }
    
    private func getFileURL(fileName: String) -> URL? {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationFileUrl = documentsUrl.appendingPathComponent(fileName)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: destinationFileUrl.path) {
                return destinationFileUrl
            }
        }
        return nil
    }
    
    private func showARViewer(url: URL) {
        DispatchQueue.main.async {
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                self.result?(FlutterError(code: "NO_ROOT_CONTROLLER",
                                        message: "Could not find root view controller",
                                        details: nil))
                return
            }
            
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.delegate = self
            previewController.currentPreviewItemIndex = 0
            self.fileURL = url
            
            // Present modally from the top-most view controller
            if let presentedViewController = rootViewController.presentedViewController {
                presentedViewController.present(previewController, animated: true) {
                    self.result?(true)
                }
            } else {
                rootViewController.present(previewController, animated: true) {
                    self.result?(true)
                }
            }
        }
    }
    
    // MARK: - QLPreviewControllerDataSource
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL! as QLPreviewItem
    }
    
    // MARK: - QLPreviewControllerDelegate
    public func previewControllerDidDismiss(_ controller: QLPreviewController) {
        // Clean up when preview is dismissed
        fileURL = nil
        result = nil
    }
}
