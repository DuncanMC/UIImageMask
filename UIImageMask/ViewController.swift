//
//  ViewController.swift
//  UIImageMask
//
//  Created by Duncan Champney on 3/20/21.
//

import UIKit

class ViewController: UIViewController {

    let transparentRect = CGRect(x: 100, y: 100, width: 80, height: 80)

    var maskLayer = CAShapeLayer()
    @IBOutlet weak var animateButton: UIButton!
    @IBOutlet weak var maskTypeControl: UISegmentedControl!

    enum MaskType: Int {
        case none
        case viewMask
        case layerMask
    }

    var imageView: UIImageView!

    var maskType: MaskType = .none {
        didSet {
            animateButton.isEnabled = maskType == .layerMask
            maskTypeControl.selectedSegmentIndex = maskType.rawValue
            addImageViewMask()

        }
    }

    @IBAction func maskTypeChanged(_ sender: Any) {
        maskType = MaskType(rawValue: maskTypeControl.selectedSegmentIndex)!
    }

    @IBAction func handleAnimateButton(_ sender: Any) {

        //Create a CABasicAnimation that will change the path of our maskLayer
        //Use the keypath "path". That tells the animation object what property we are animating
        let animation = CABasicAnimation(keyPath: "path")

        animation.autoreverses = true //Make the animation reverse back to the oringinal position once it's done

        //Use ease-in, ease-out timing, which looks smooth
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        animation.duration = 0.5 //Make each step in the animation last 0.3 seconds.


        let transparentRect: CGRect

        //Randomly either animate the transparent rect to a different shape or shift it
        if Bool.random() {
            //Make the transparent rect taller and skinnier
            transparentRect = self.transparentRect.inset(by: UIEdgeInsets(top: -20, left: 20, bottom: -20, right: 20))
        } else {
            //Shift the transparent rect to by a random amount that still says inside the image view's bounds.
            transparentRect = self.transparentRect
                .offsetBy(dx: CGFloat.random(in: -100...20), dy: CGFloat.random(in: -120...120))
                .inset(by: UIEdgeInsets(top: -30, left: -30, bottom: -30, right: -30))
        }

        let cornerRadius: CGFloat = CGFloat.random(in: 0...30)
        //install the new path as the animation's `toValue`. If we dont specify a `fromValue` the animation will start from the current path.
        animation.toValue = maskPath(transparentRect: transparentRect, cornerRadius: cornerRadius).cgPath

        //add the animation to the maskLayer. Since the animation's `keyPath` is "path",
        //it will animate the layer's "path" property to the "toValue"
        maskLayer.add(animation, forKey: nil)

        //Since we don't actually change the path on the mask layer, the mask will revert to it's original path once the animation completes.
    }

    /**
     Function to create a UIImage that is mostly opaque, with a transparent rounded rect "knockout" in it. Such an image might be used ask a mask
     for another view, where the transparent "knockout" appears as a hole in the view that is being masked.
        - Parameter size:  The size of the image to create
        - Parameter transparentRect: The (rounded )rectangle to make transparent in the middle of the image.
        - Parameter cornerRadius: The corner radius ot use in the transparent rectangle. Pass 0 to make the rectangle square-cornered.
     */
    func imageWithTransparentRoundedRect(size: CGSize, transparentRect: CGRect, cornerRadius: CGFloat) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { (context) in
            let frame = CGRect(origin: .zero, size: size)
            UIColor.white.setFill()
            context.fill(frame)
            let roundedRect = UIBezierPath(roundedRect: transparentRect, cornerRadius: cornerRadius)
            context.cgContext.setFillColor(UIColor.clear.cgColor)
            context.cgContext.setBlendMode(.clear)

            roundedRect.fill()
        }
        return image
    }

    /**
     function to return a UIBezierPath that contains a rectangle the full size of the maskLayer, and a smaller rect inside it.
     - Parameter transparentRect:  The inside transparent rect to draw
     - Parameter cornerRadius:  The corner radius to use in the inner transparent rectnagle. Pass 0 for a sharp-cornered rectangle
     */
    func maskPath(transparentRect: CGRect, cornerRadius: CGFloat) -> UIBezierPath {
        let fullRect = UIBezierPath(rect: maskLayer.frame)
        let roundedRect = UIBezierPath(roundedRect: transparentRect, cornerRadius: cornerRadius)
        fullRect.append(roundedRect)
        return fullRect
    }

    func addImageViewMask() {
        switch maskType {
        case .none:
            imageView.mask = nil
            imageView.layer.mask = nil
        case .viewMask:
            //Create a mask image view the same size as the (image) view we will be masking
            let maskView = UIImageView(frame: imageView.bounds)

            //Build an opaque UIImage with a transparent "knockout" rounded rect inside it.
            let maskImage = imageWithTransparentRoundedRect(size: imageView.bounds.size, transparentRect: transparentRect, cornerRadius: 20)

            //Install the image with the "hole" into the mask image view
            maskView.image = maskImage

            //Make the maskView the ImageView's mask
            imageView.mask = maskView /// set the mask
        case .layerMask:
            print("Not yet implemetent")
            imageView.mask = nil
            imageView.layer.mask = nil
            maskLayer.frame = imageView.bounds

            maskLayer.path = maskPath(transparentRect: transparentRect, cornerRadius: 20).cgPath
            imageView.layer.mask = maskLayer
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.strokeColor = UIColor.clear.cgColor

        //Set the view controller's content view background color to cyan so we can
        //see it through the hole we make in the image view.
        self.view.backgroundColor = .cyan
        let size = CGSize(width: 200, height: 300)
        let origin = CGPoint(x: 50, y: 50)
        let frame =  CGRect(origin: origin, size: size)
        let backgroundImageView = UIImageView(frame: frame)
        backgroundImageView.image = UIImage(named:"Bernie")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)

        imageView = UIImageView(frame: frame)
        imageView.image = UIImage(named: "TestImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.layer.borderWidth = 2
        maskType = .none
    }
}

