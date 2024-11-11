//
//  ImageDetailViewController.swift
//  IosMachineTest
//
//  Created by Shahrukh on 09/11/24.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    //MARK: - OutLet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneTXt: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
              
    }
    
    @IBAction func submitBtn(_ sender: Any) {
        
        if let firstName = firstName.text, firstName.isEmpty || firstName.count < 2 {
             showAlert(on: self, title: "", message: "Please enter a valid first name (at least 2 characters)")
             return
         }
         
         // Check if last name is empty or too short
         if let lastName = lastName.text, lastName.isEmpty || lastName.count < 2 {
             showAlert(on: self, title: "", message: "Please enter a valid last name (at least 2 characters)")
             return
         }
         
         // Check if email is empty or invalid format
         if let emailText = emailTxt.text, emailText.isEmpty || !isValidEmail(emailText) {
             showAlert(on: self, title: "", message: "Please enter a valid email address")
             return
         }
         
         // Check if phone number is empty or has an invalid length
         if let phoneText = phoneTXt.text, phoneText.isEmpty || phoneText.count < 10 {
             showAlert(on: self, title: "", message: "Please enter a valid phone number (at least 10 digits)")
             return
         }
        let params = [
            "first_name" : self.firstName.text!,
            "last_name" : self.lastName.text!,
            "email" : self.emailTxt.text!,
            "phone" : self.phoneTXt.text!
        ]
        
        
        postData(params: params, img: self.imageView.image!)
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    func postData(params : [String : Any],img : UIImage){
        let url = URL(string: "http://dev3.xicomtechnologies.com/xttest/savedata.php")!
        var resource = Resource<saveImageResoponse>(url: url)
        resource.httpMethods = .post
        resource.body = params
          
        WebService().load(resource: resource,image: img) { result in

            switch result{
            case .success(let imageModel):
                print(imageModel)
                self.showAlert(on: self, title: "Hey", message: imageModel.message)
            case .failure(_):
                print(result)
            }
        }
    }
    
    
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)        
    }
    

    // Function to show an alert with a title, message, and an optional action
    func showAlert(on viewController: UIViewController, title: String, message: String, buttonTitle: String = "OK", completion: (() -> Void)? = nil) {
        // Create an alert controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add an action button to the alert
        let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
            // Execute completion handler if provided
            completion?()
        }
        
        // Add the action to the alert controller
        alert.addAction(action)
        
        // Present the alert on the given view controller
        viewController.present(alert, animated: true, completion: nil)
    }

}
