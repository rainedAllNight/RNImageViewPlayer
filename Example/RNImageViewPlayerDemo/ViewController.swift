//
//  ViewController.swift
//  RNImageViewPlayerDemo
//
//  Created by rainedAllNight on 2017/2/1.
//  Copyright © 2017年 rainedAllNight. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RNImageViewPlayerDelegate {

    @IBOutlet weak var imagePlayer: RNImageViewPlayer!
    let images = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg"]
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePlayer.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailViewController = segue.destination as? DetailViewController
        let index = sender as? Int ?? 0
        detailViewController?.title = "这是第\(index + 1)张图片"
    }
    
    // MARK: - RNImageViewPlayerDelegate
    
    func imagePlayerNumberOfItems(imagePlayer: RNImageViewPlayer) -> Int {
        return self.images.count
    }
    
    func imagePlayer(imagePlayer: RNImageViewPlayer, willLoadImageWith imageView: UIImageView, at index: Int) {
        imageView.image = UIImage(named: self.images[index])
    }
    
    func imagePlayer(imagePlayer: RNImageViewPlayer, didSelectItemAt index: Int) {
        print(index)
        self.performSegue(withIdentifier: "DetailSegue", sender: index)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

