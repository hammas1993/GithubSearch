//
//  ViewController.swift
//  GithubSearch
//
//  Created by Hammas Naik on 17/08/2021.
//

import UIKit
import Alamofire

class GithubSearch: UIViewController
{
    @IBOutlet weak var searchBar: UISearchBar!
    {
        didSet
        {
           searchBar.returnKeyType = .done
           searchBar.enablesReturnKeyAutomatically = true
        }
    }
    @IBOutlet weak var tbl      : UITableView!
    
    var userArr  = Hither()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
}

//MARK: - Table View Delegates

extension GithubSearch:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userArr.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
       
        cell.textLabel?.text = userArr.items?[indexPath.row].full_name
        cell.detailTextLabel?.text = userArr.items?[indexPath.row].html_url
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let url = URL(string: userArr.items![indexPath.row].html_url ?? "")
        {
            UIApplication.shared.open(url)
        }
    }
}





//MARK: - Search Bar Delegates
extension GithubSearch:UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
//        print(searchBar.text!)
        
        if searchBar.text != ""
        {
            GetPosts(text: searchBar.text!)
        }
        else
        {
            
            DispatchQueue.main.async
            { [self] in
                tbl.reloadData()
            }
        }
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let totalCharacters = (searchBar.text?.appending(text).count ?? 0) - range.length
        return totalCharacters <= 30
    }
    
    
    func GetPosts(text:String)
    {
        let url = "https://api.github.com/search/repositories?q=\(text)"
        let headers:HTTPHeaders = [.contentType("application/json")]
//        print(headers)
        
        N_C.getRequestList(Url: url, Header: headers)
        {(arr, success,data)  in
//            print(arr)
            DispatchQueue.main.async
            { [self] in
                do
                {
                    let data = try JSONDecoder().decode(Hither.self, from: data)
//                    print(data.items?.count ?? 0)
                    userArr = data
                    DispatchQueue.main.async
                    {
                        tbl.reloadData()
                    }
                }
                catch
                {
//                   print("Error")
                }
            }
        }
    }
    
    
}



var N_C = Network()
class Network
{
    func getRequestList(Url:String, Header:HTTPHeaders ,completion: @escaping (NSDictionary,Bool,Data) -> ())
    {
        AF.request(URL(string: Url)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Header).responseJSON
        { (response:DataResponse) in
            
            switch response.result
            {
                case .success:
                    if let JSON = response.value
                    {
//                        print("JSON: \(JSON)")
                        let dic = (JSON as? NSDictionary ?? [:])
//                        print(dic)
                        completion(dic,true,response.data ?? Data())
                    }
                    else
                    {
                        completion([:],true,response.data ?? Data())
                    }
                case .failure(let error):
//                    print(error)
                    completion([:],false,response.data ?? Data())
            }
        }
    }
}
