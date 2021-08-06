//
//  AddNewPlace.swift
//  TableView
//
//  Created by Саша Гужавин on 01.10.2020.
//

import UIKit

class AddNewPlace: UITableViewController {
    
    var imageIsChenge = false
    var currentPlace: Place?
    
    // MARK: - Outlet
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    @IBOutlet weak var mapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        setupEditSkreen()
    }
    
    // MARK: - Did select row at index path
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let actionSheet = UIAlertController(title: nil,
                                               message: nil,
                                               preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) {_ in
                self.chooseImagePicker(source: .camera)
            }
            let photo = UIAlertAction(title: "Photo", style: .default) {_ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            let cancle = UIAlertAction(title: "Cancle", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancle)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "showMap" {
            return
        }
        let mapVC = segue.destination as! MapViewController
        
        mapVC.place = currentPlace
    }
    
    
    // MARK: - Sace new place
    
    func savePlace() {
        
        var image:UIImage?
        
        if imageIsChenge {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "food")
        }
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData)
        
        if currentPlace?.imageData != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditSkreen() {
        if currentPlace?.imageData != nil {
            
            setupNavigationBar()
            imageIsChenge = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            placeImage.image = image
            
            mapButton.isEnabled = true
        } else {
            mapButton.isEnabled = false
            return
        }
    }
    
    private func setupNavigationBar() {
        if let tapItem = navigationController?.navigationBar.topItem {
            tapItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        saveButton.isEnabled = true
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
    }
    
    // MARK: - Exit from view
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// MARK: - Table view data source

extension AddNewPlace: UITextFieldDelegate {
     
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChange() {
        if placeName.text?.isEmpty == false{
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: - Choose image

extension AddNewPlace: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func chooseImagePicker (source:UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFit
        placeImage.clipsToBounds = true
        imageIsChenge = true
        
        dismiss(animated: true)
    }
}
