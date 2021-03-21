//
//  ViewController.swift
//  UIImageMask
//
//  Created by Duncan Champney on 3/20/21.
//

import UIKit

class ViewController: UIViewController {

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the view controller's content view background color to cyan so we can
        ///see it through the hole we make in the image view.
        self.view.backgroundColor = .cyan
        let size = CGSize(width: 200, height: 300)
        let origin = CGPoint(x: 50, y: 50)
        let frame =  CGRect(origin: origin, size: size)
        let imageView = UIImageView(frame: frame)
        imageView.image = UIImage(named: "TestImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.layer.borderWidth = 2

        //Create a mask image view the same size as the (image) view we will be masking
        let maskView = UIImageView(frame: imageView.bounds)

        //Build an opaque UIImage with a transparent "knockout" rounded rect inside it.
        let transparentRect = CGRect(x: 100, y: 100, width: 80, height: 80)
        let maskImage = imageWithTransparentRoundedRect(size: size, transparentRect: transparentRect, cornerRadius: 20)

        //Install the image with the "hole" into the mask image view
        maskView.image = maskImage

        //Make the maskView the ImageView's mask
        imageView.mask = maskView /// set the mask
    }
}

