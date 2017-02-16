//
//  CustomViewController.swift
//  RNImageViewPlayerDemo
//
//  Created by rainedAllNight on 2017/2/16.
//  Copyright © 2017年 rainedAllNight. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController, RNImageViewPlayerDelegate {
    
    let images = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg"]
    @IBOutlet weak var imagePlayer: RNImageViewPlayer!
    
    // MARK: - View lefe cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePlayer.delegate = self
        self.imagePlayer.collectionView?.register(UINib.init(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomCollectionViewCell")
        // Do any additional setup after loading the view.
    }
    
    // MARK: - View life cycle
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - RNImageViewPlayerDelegate
    
    func imagePlayerNumberOfItems(imagePlayer: RNImageViewPlayer) -> Int {
        return self.images.count
    }
    
    func imagePlayer(imagePlayer: RNImageViewPlayer, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imagePlayer.collectionView?.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        cell.imageView.image = UIImage(named: self.images[indexPath.item])
        cell.label.text = "第\(indexPath.item + 1)张图片"
        return cell
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
