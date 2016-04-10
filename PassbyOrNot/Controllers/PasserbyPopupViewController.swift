//
//  PasserbyPopupViewController.swift
//  PassbyOrNot
//
//  Created by CHIBANG QN on 4/9/16.
//  Copyright © 2016 Consiiii. All rights reserved.
//

import UIKit

class PasserbyPopupViewController: UIViewController {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    
    var preparedImage: UIImage? = UIImage(named: "headicon") {
        didSet{
            userImage.image = preparedImage
        }
    }
    
    var userName: String = "Got It" {
        didSet{
            checkButton.setTitle(userName, forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        checkButton.addTarget(self, action:Selector("dismissView:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        userImage.image = preparedImage
        checkButton.setTitle(userName, forState: .Normal)
        checkButton.frame.origin = CGPointMake(self.view.center.x, self.view.center.y)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: .CurveEaseIn, animations: {
                self.userImage.frame.size = CGSizeMake(270, 270)
                self.userImage.center = self.view.center
        }) { (_) in
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissView(sender: AnyObject){
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
