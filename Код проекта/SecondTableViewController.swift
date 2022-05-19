//
//  SecondTableViewController.swift
//  ScrolView
//
//  Created by Игорь Островский on 04.05.2022.
//

import UIKit
import Cosmos


class SecondTableViewController: UITableViewController {
    

    var currentPlace:Place!
    var imageIsChanged = false
    var currentRating = 0.0
    
    @IBOutlet var placeImage:UIImageView!
    @IBOutlet var saveButton:UIBarButtonItem!
    @IBOutlet var placeName:UITextField!
    @IBOutlet var placeLocation:UITextField!
    @IBOutlet var placeType:UITextField!
    @IBOutlet var ratingControl:RatingControl!
    @IBOutlet var cosmosView:CosmosView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
        //cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = {
            rating in self.currentRating  = rating
        }
    }
    

    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }*/
    //MARK:Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo (1)")
            
            let actionSheet = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                // TODO:chooseImagePicker
            self.chooseImagePicker(source: .camera)
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in }
            photo.setValue(photoIcon, forKey:   "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                // TODO: ChouseImagePicker
            self.chooseImagePicker(source: .photoLibrary)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                
                actionSheet.addAction(camera)
                actionSheet.addAction(photo)
                actionSheet.addAction(cancel)
                
                present(actionSheet, animated: true)
        
                
            
        }else{
            view.endEditing(true)
        }
    }
    func savePlace(){
        
        
        var image:UIImage?
        
        if imageIsChanged{
            image = placeImage.image
        }else{
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        let imageData = image?.pngData()
        
        let newPlace = Place(
                        name: placeName.text!,
                        location: placeLocation.text,
                        type: placeType.text,
                        imageData: imageData,
                        rating: currentRating
                            
                            )
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        }else{
            StorageManager.saveObject(newPlace)
        }
        
    }

    private func setupEditScreen(){
        if currentPlace != nil {
            
            setupNavigationBar()
            imageIsChanged = true
            guard let  data = currentPlace?.imageData, let image = UIImage(data: data) else{return}
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            cosmosView.rating = currentPlace.rating
        }
    }
    
    private func setupNavigationBar(){
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain , target: nil, action: nil)
            
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    @IBAction func cancelAction(_ sender:Any){
        dismiss(animated: true)
    }
}
// MARK: Text field deleagate
//Скрываем клавиатуру по нажатию кнопки Done
extension SecondTableViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged(){
        if placeName.text?.isEmpty == false{
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
    }
}

//MARK: Work with image

extension SecondTableViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            //Функция которая позволяет пользователю взаимодействовать и редактировать картинку перед ее использованием
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker,animated: true)
        }
       func imagePickerController(_ picker:UIImagePickerController,didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey:Any]){
            
            placeImage.image = info[.editedImage] as? UIImage
            placeImage.contentMode = .scaleAspectFill
            //Обрезка по границам
            placeImage.clipsToBounds = true
           
           imageIsChanged = true
            dismiss(animated: true)
            
        }
        
        

}
}
