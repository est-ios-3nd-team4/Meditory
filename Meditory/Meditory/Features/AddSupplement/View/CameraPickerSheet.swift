//
//  TextRecognitionView.swift
//  Meditory
//
//  Created by 홍승아 on 8/11/25.
//

import SwiftUI
import UIKit
import Vision

struct CameraPickerSheet: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  var onTextRecognized: (String) -> Void
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.allowsEditing = false
    picker.delegate = context.coordinator
    picker.modalPresentationStyle = .fullScreen
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
  
  func makeCoordinator() -> Coordinator { Coordinator(self) }
  
  final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: CameraPickerSheet
    
    init(_ parent: CameraPickerSheet) {
      self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      if let image = info[.originalImage] as? UIImage {
        imageDidSelect(image)
      }
      parent.isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.isPresented = false
    }
    
    private func imageDidSelect(_ image: UIImage) {
      guard let cgImage = image.cgImage else { return }
      
      let request = VNRecognizeTextRequest()
      request.recognitionLevel = .accurate
      request.usesLanguageCorrection = true
      request.recognitionLanguages = ["ko-KR"]
      request.revision = VNRecognizeTextRequestRevision3
      
      let handler = VNImageRequestHandler(cgImage: cgImage)
      
      Task {
        do {
          try handler.perform([request])
          if let observation = request.results {
            let text = observation
              .compactMap { $0.topCandidates(1).first?.string }
              .joined(separator: "\n")
            
            self.parent.onTextRecognized(text)
          }
        } catch {
          print(error)
        }
      }
    }
  }
}
