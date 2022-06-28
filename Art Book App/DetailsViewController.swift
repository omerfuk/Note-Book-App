//
//  DetailsViewController.swift
//  Art Book App
//
//  Created by Ömer Faruk Kılıçaslan on 28.06.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearTextfield: UITextField!
    @IBOutlet weak var artistTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var chosenPainting = ""
    var chosenPaintingId: UUID?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboard()
        configureImageGesture()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            //Core data fetch
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            
            let idString = chosenPaintingId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do {
              let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameTextfield.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistTextfield.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearTextfield.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                            
                    }
                }
            } catch {
                print("Error")
            }
            
            
            
        }
        else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
            nameTextfield.text = ""
            artistTextfield.text = ""
            yearTextfield.text = ""
            
        }
        

        
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameTextfield.text!, forKey: "name")
        newPainting.setValue(artistTextfield.text!, forKey: "artist")
        
        if let year = Int(yearTextfield.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("Error occured")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)

        
    }
    
    func configureKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    func configureImageGesture(){
        imageView.isUserInteractionEnabled = true
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapGesture)
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
}

extension DetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
