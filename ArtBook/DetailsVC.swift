//
//  DetailsVC.swift
//  ArtBook
//
//  Created by Burak Karagül on 12.01.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if chosenPainting != "" {
            saveButton.isEnabled=false //Tıklanamaz hale getirir buton sönük olur.
            // saveButton.isHidden=true   //Bu kod ise tamamen gizli hale getirir.

         
            let appDelegate=UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            
            let idString = chosenPaintingID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id =%@", idString!)
            
            fetchRequest.returnsObjectsAsFaults=false
            
//            Veri çekme işlemi
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text=name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text=artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data:imageData)
                            imageView.image=image
                        }
                        
                    }
                }
            }catch{
                print("DetailsVC Veri çekme hatası")
            }
            }
        else {
            saveButton.isEnabled=false
        }
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
//                              ******************
        

        imageView.isUserInteractionEnabled=true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
//                      **********************************
        
    }
    
//                  Fotoğraf seçme ve ekleme fonksiyonu objective C
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true //Bu satıdaki kod ise kullanıcı foto yüklerken düzenlemeyi açar (Kırpma, Zoomlama)
        present(picker, animated: true, completion: nil)
    }
//                      *********************************
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage /*yada editing image*/] as? UIImage
        saveButton.isEnabled=true
        self.dismiss(animated: true, completion: nil)
    }
    
//                  *   *   *   *   *   *   *   *   *   *
    
//              Objective c action fonksiyonu tanımlama 
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
//                      ***************************************
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
//                          Veri kaydetme işlemleri
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        //                             ********************

//                                      Attributes
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")

        if let year = Int(yearText.text!){
            
        newPainting.setValue(year, forKey: "year")
            
        }
//        Aşağıdaki satırda veriler için otomatik id oluşturuyoruz.
        newPainting.setValue(UUID(), forKey: "id")
        
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5) /**resim için kalite oranı**/
        
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
            
        } catch{
            
            print("error")
        }
//  Sisteme yeni veri girildiğini söyleyen bir mesaj yolluyoruz heryerden alabiliriz ve gelen mesaj içeriğine göre işlem yaptırabiliriz
        
        NotificationCenter.default.post(name: NSNotification.Name("NewData"), object: nil)
            
//                  *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    

}
