//
//  ImageListViewController.swift
//  IosMachineTest
//
//  Created by Shahrukh on 09/11/24.
//

import UIKit

class ImageListViewController: UIViewController {
    
    // MARK: - OutLet
    @IBOutlet weak var imageListTableView: UITableView!
    
    //MARK: - Propertise
    var model : ImageModel?
    var images: [Image] = []
    private var activityIndicator: UIActivityIndicatorView!
    var offset = 0
    private var loadMoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.navigationController?.isNavigationBarHidden = true
        registerTableViewCell()
        getImageList()
        imageListTableView.estimatedRowHeight = 200
        imageListTableView.rowHeight = UITableView.automaticDimension
        loadMoreButton.isHidden = true
    }
    
    // MARK: - Helper
    func configureUI(){
        imageListTableView.dataSource = self
        imageListTableView.delegate = self
        
        // Set the custom footer view
        let footerView = createFooterView()
        imageListTableView.tableFooterView = footerView
    }
    
    func createFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: imageListTableView.frame.width, height: 50))
        
        // Create the "Load More" button
        let loadMoreButton = UIButton(type: .system)
        loadMoreButton.setTitle("Load More", for: .normal)
        loadMoreButton.setTitleColor(.black, for: .normal)
        loadMoreButton.addTarget(self, action: #selector(loadMoreButtonTapped), for: .touchUpInside)
        loadMoreButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the activity indicator (loader)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        // Add both the button and the loader to the footer view
        footerView.addSubview(loadMoreButton)
        footerView.addSubview(activityIndicator)

        // Center the button and loader horizontally in the footer view
        NSLayoutConstraint.activate([
            loadMoreButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor, constant: -40),
            loadMoreButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: loadMoreButton.trailingAnchor, constant: 8),
            activityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        self.loadMoreButton = loadMoreButton  // Assign to the instance property
        self.activityIndicator = activityIndicator  // Assign to the instance property
        
        return footerView
    }

    
    func registerTableViewCell(){
        let nib = UINib(nibName: "ImageListTableViewCell", bundle: nil)
        self.imageListTableView.register(nib, forCellReuseIdentifier: "ImageListTableViewCell")
    }
    
    @objc func loadMoreButtonTapped(_ sender: UIButton) {
        activityIndicator.startAnimating()
          offset += 1
        getImageList()
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
      }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ImageListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageListTableViewCell", for: indexPath) as! ImageListTableViewCell
        
        let urlString = self.images[indexPath.row].xtImage
       // cell.customImageView.image =
        if let imageUrl = URL(string: urlString) {
            loadImageFromURL(imageUrl) { image in
                if let image = image {
                    // Set the image to the UIImageView
                    cell.configure(with: image)
                } else {
                    
                }
            }
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyBoard.instantiateViewController(withIdentifier: "ImageDetailViewController") as! ImageDetailViewController
        let urlString = self.images[indexPath.row].xtImage
        if let imageUrl = URL(string: urlString) {
            loadImageFromURL(imageUrl) { image in
                if let image = image {
                    detailVC.imageView.image = image
                } else {
                    
                }
            }
        }
        self.navigationController?.pushViewController(detailVC, animated: false)
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
}

// Function to fetch the image from a URL and return it as a UIImage asynchronously
func loadImageFromURL(_ url: URL, completion: @escaping (UIImage?) -> Void) {
    // Create a URLSession data task to download the image asynchronously
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Handle errors
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        // Ensure we got valid data
        guard let data = data, let image = UIImage(data: data) else {
            print("Error: Data is not valid or image could not be created.")
            completion(nil)
            return
        }
        
        // Return the image on the main thread since UI updates should be on the main thread
        DispatchQueue.main.async {
            completion(image)
        }
    }.resume() // Start the data task
}


//MARK: -- API Calling
extension ImageListViewController {
    
    
    func getImageList() {
        let url = URL(string: "http://dev3.xicomtechnologies.com/xttest/getdata.php")!
        let bodyParams = ["user_id": "108", "offset": offset, "type": "popular"] as [String : Any]
        var resource = Resource<ImageModel>(url: url)
        resource.httpMethods = .post
        resource.body = bodyParams
          
        WebService().load(resource: resource) { result in
         
            switch result{
            case .success(let imageModel):
                print(imageModel)
                self.model = imageModel
                self.images += imageModel.images
                
                DispatchQueue.main.async {
                    self.loadMoreButton.isHidden = false
                    self.imageListTableView.reloadData()
                }
                
            case .failure(_):
                print(result)
            }
        }
    }
    
}
