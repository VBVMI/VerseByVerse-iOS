//
//  VideoDetailViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 7/05/17.
//  Copyright © 2017 Tom Carey. All rights reserved.
//

import UIKit

class VideoDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var video: Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleLabel.text = video.title
        descriptionTextView.text = video.descriptionText
        timeLabel.text = video.videoLength
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
