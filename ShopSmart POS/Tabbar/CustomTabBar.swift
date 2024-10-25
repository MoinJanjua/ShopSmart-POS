import UIKit

class CustomTabBar: UITabBar {
    
    private var shapeLayer: CALayer?
    private var selectionCircle = UIView()
    private let plusButton = UIButton()

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addShape()
        setupSelectionLine() // Add selected tab  Line
        
       
    }

    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.systemPink.cgColor
        shapeLayer.fillColor = UIColor.systemRed.withAlphaComponent(0.2).cgColor
        shapeLayer.lineWidth = 1.0

        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
    }

    private func createPath() -> CGPath {
        let height: CGFloat = 35.0
        let path = UIBezierPath()

        let centerWidth = self.frame.width / 2
        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: centerWidth - height, y: 0)) // the beginning of the trough

        path.addQuadCurve(to: CGPoint(x: centerWidth + height, y: 0),
                          controlPoint: CGPoint(x: centerWidth, y: height + 10))

        path.addLine(to: CGPoint(x: self.frame.width, y: 0)) // complete the rect
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()

        return path.cgPath
    }

    private func setupSelectionLine() {
        let circleSize: CGFloat = 30.0
        selectionCircle.frame.size = CGSize(width: circleSize, height: 2)
        selectionCircle.backgroundColor = UIColor.systemPink.withAlphaComponent(0.8)
        
        selectionCircle.center = CGPoint(x: 45, y: 50) // Start at first tab position
        self.addSubview(selectionCircle)
    }

    private func moveSelectionLine(to tabIndex: Int) {
        guard let items = self.items, tabIndex < items.count else { return }
        let tabWidth = self.frame.width / CGFloat(items.count)
        let newCenterX = tabWidth * CGFloat(tabIndex) + tabWidth / 2
        UIView.animate(withDuration: 0.3) {
            self.selectionCircle.center.x = newCenterX
        }
    }


 

//    func MoveplusButtonScreen() {
//        print("Plus button clicked")
//        
//        // Assuming the view controller's storyboard ID is "plusbuttonScreen"
//        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name
//        if let newViewController = storyboard.instantiateViewController(withIdentifier: "plusbuttonScreen") as? PlusbuttonScreenViewController {
//            print("View controller initialized")
//            
//            // Find the current navigation controller and push the view controller
//            if let topController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
//                if let navigationController = topController.selectedViewController as? UINavigationController {
//                    navigationController.pushViewController(newViewController, animated: false)
//                }
//            }
//        }
//    }


 
  
    func updateLinePosition(selectedIndex: Int) {
        print("Updating line position :\(selectedIndex)")
        moveSelectionLine(to: selectedIndex)
    }
}
