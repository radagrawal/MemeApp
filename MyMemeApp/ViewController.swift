//
//  ViewController.swift
//  MyMemeApp
//
//  Created by Radhika Agrawal on 29/09/21.
//

import UIKit
import OCDefaultImplementation
import Combine

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    private lazy var cancellables = Set<AnyCancellable>()
    let myImage: UIImageView = {
       let theImageView = UIImageView()
       theImageView.image = UIImage(named: "choose-button.png")
        theImageView.backgroundColor = UIColor(named: "red")
       theImageView.translatesAutoresizingMaskIntoConstraints = false //You need to call this property so the image is added to your view
       return theImageView
    }()
    
    var topTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "TOP"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        return textField
    }()
    var bottomTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "BOTTOM"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center

        return textField
    }()
    
    let memeAppview:UIView = {
     let view = UIView()
     view.backgroundColor = .gray
     view.translatesAutoresizingMaskIntoConstraints = false
     return view
   }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        memeAppview.addSubview(myImage)
        memeAppview.addSubview(topTextField)
        memeAppview.addSubview(bottomTextField)
        view.addSubview(memeAppview)
        setUP()
        // Do any additional setup after loading the view.
    }
    func setUP(){
        memeAppview.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        memeAppview.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        memeAppview.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        memeAppview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
     
        topTextField.topAnchor.constraint(equalTo:memeAppview.topAnchor, constant:100).isActive = true
        topTextField.leftAnchor.constraint(equalTo:memeAppview.leftAnchor, constant:20).isActive = true
        topTextField.rightAnchor.constraint(equalTo:memeAppview.rightAnchor, constant:-20).isActive = true
        topTextField.heightAnchor.constraint(equalToConstant:50).isActive = true
        
        myImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        myImage.centerYAnchor.constraint(equalTo: memeAppview.centerYAnchor).isActive = true
        myImage.leftAnchor.constraint(equalTo:memeAppview.leftAnchor, constant:20).isActive = true
        myImage.rightAnchor.constraint(equalTo:memeAppview.rightAnchor, constant:-20).isActive = true
        
        bottomTextField.topAnchor.constraint(equalTo:myImage.topAnchor, constant:200).isActive = true
        bottomTextField.leftAnchor.constraint(equalTo:memeAppview.leftAnchor, constant:20).isActive = true
        bottomTextField.rightAnchor.constraint(equalTo:memeAppview.rightAnchor, constant:-20).isActive = true
        bottomTextField.heightAnchor.constraint(equalToConstant:50).isActive = true
      
        //Add Tool Bar
        let pickFromAlbum = UIBarButtonItem(title: "Pick", style:UIBarButtonItem.Style.plain, target: self, action: #selector(self.pickAnImage(_:)))
        let pickFromCamera = UIBarButtonItem(title: "Camera", style:UIBarButtonItem.Style.plain, target: self, action: #selector(self.pickAnImageFromCamera(_:)))
        let share = UIBarButtonItem(title: "Share", style:UIBarButtonItem.Style.plain, target: self, action: #selector(self.shareAnImage(_:)))
        navigationItem.leftBarButtonItem = share
            self.navigationItem.rightBarButtonItems = [pickFromAlbum,pickFromCamera]
        //pickFromCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    @objc func shareAnImage(_ sender: Any){
        let memeImage = generateMemedImage()
                
                let activityViewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
                
                activityViewController.completionWithItemsHandler = { activity, completed, items, error in
                    if completed
                    {
                        //Save the image
                        self.save()
                        //Dismiss the view controller
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
        present(activityViewController, animated: true, completion: nil)
    }
    @objc func pickAnImage(_ sender:UIBarButtonItem!)
    {
        let pickController = UIImagePickerController()
        pickController.delegate = self
        pickController.sourceType = .photoLibrary
        present(pickController, animated: true, completion: nil)
    }
    
    @objc func pickAnImageFromCamera(_ sender:UIBarButtonItem!)
    {

        do {
            let camCoord = try OneCameraCoordinator()
            
            navigationController?.addChild(camCoord.rootViewController)
            navigationController?.view.addConstrainedSubview(camCoord.rootViewController.view, insets: .zero, target: .bounds)
            camCoord.start()
            camCoord.eventPublisher.sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .closed:
                    camCoord.rootViewController.view.removeFromSuperview()
                    camCoord.rootViewController.removeFromParent()
                case .completed(let result):
                    // Handle this eventually
                    result.getFinalVideo(progress: { prog in print("progress:", prog) }) { [weak self] exportResult in
                        guard let self = self else { return }
                        switch exportResult {
                        case .failure(let error):
                            print("Final render failed: \(error)")
                        case .success((let url, _)):
                            print("Got final video: \(url)")
                        }
                        result.cleanupProject()
                        DispatchQueue.main.async {
                            camCoord.rootViewController.view.removeFromSuperview()
                            camCoord.rootViewController.removeFromParent()
                        }
                    }
                }
            }.store(in: &cancellables)
        } catch {
            assertionFailure("Failed to load camera coordinator: \(error)")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        myImage.image = image
       }
       dismiss(animated: true, completion: nil)
   }
    
    
    /*Mark: Meme Creation*/
       func generateMemedImage() -> UIImage
       {
        //setVisability(hidden: true)
           
           //create an image context
           UIGraphicsBeginImageContext(view.frame.size)
           //takes a snapshot of the screen
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
           //get the meme Image from UIGraphics
        let memeImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
           UIGraphicsEndImageContext()
           
          // setVisability(false)
           
           return memeImage
       }
   /*    func setVisability(hidden: Bool)
       {
           self.toolBar.hidden = hidden
           self.navigationBar.hidden = hidden
       }*/
       func save() {
           let memeImage = generateMemedImage()
           //Create the meme
        _ = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: myImage.image, memeImage: memeImage)
           
       }
    
}

