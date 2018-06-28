import UIKit

class DraggableView: UIView {

    var keyTag: String {
        return "DraggableView"
    }

    private struct Constants {
        static let keyCenterX = "CenterX"
        static let keyCenterY = "CenterY"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupGestureRecognizer()
        self.loadLocation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupGestureRecognizer()
        self.loadLocation()
    }

    private func setupGestureRecognizer() {
        // Set up pan gesture for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        if let superview = self.superview as? ContainerView {
            superview.bringSubview(toFront: self)


            let translation = sender.translation(in: superview)
            var newCenterX = self.center.x + translation.x
            var newCenterY = self.center.y + translation.y

            // Validation to prevent controls from being dragged outside of the screen
            if newCenterX + self.bounds.width / 2 >= superview.bounds.width {
                newCenterX = superview.bounds.width - self.bounds.width / 2
            } else if newCenterX <= self.bounds.width / 2 {
                newCenterX = self.bounds.width / 2
            }

            if #available(iOS 11, *) {
                let safeArea = superview.safeAreaInsets

                if newCenterY + self.bounds.height / 2 >= superview.lowerBounds {
                    newCenterY = superview.lowerBounds - self.bounds.height / 2
                } else if newCenterY <= self.bounds.height / 2 + safeArea.top {
                    newCenterY = self.bounds.height / 2 + safeArea.top
                }
            }
            else {
                let statusBarHeight = UIApplication.shared.statusBarFrame.height

                if newCenterY + self.bounds.height / 2 >= superview.lowerBounds {
                    newCenterY = superview.lowerBounds - self.bounds.height / 2
                } else if newCenterY <= self.bounds.height / 2  + statusBarHeight {
                    newCenterY = self.bounds.height / 2 + statusBarHeight
                }
            }

            self.center = CGPoint(x: newCenterX, y: newCenterY)
            sender.setTranslation(CGPoint.zero, in: superview)
        }

        if sender.state == .ended {
            print(center)

            // Save preference
            self.saveLocation()
        }
    }
    
    public func update() {
        if let superview = self.superview as? ContainerView {
            // Validation to prevent controls from being dragged outside of the screen
            if self.center.x + self.bounds.width / 2 >= superview.bounds.width {
                self.center.x = superview.bounds.width - self.bounds.width / 2
            } else if self.center.x <= self.bounds.width / 2 {
                self.center.x = self.bounds.width / 2
            }
            
            if #available(iOS 11, *) {
                let safeArea = superview.safeAreaInsets
                
                if self.center.y + self.bounds.height / 2 >= superview.lowerBounds {
                    self.center.y = superview.lowerBounds - self.bounds.height / 2
                } else if self.center.y <= self.bounds.height / 2 + safeArea.top {
                    self.center.y = self.bounds.height / 2 + safeArea.top
                }
            }
            else {
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                
                if self.center.y + self.bounds.height / 2 >= superview.lowerBounds {
                    self.center.y = superview.lowerBounds - self.bounds.height / 2
                } else if self.center.y <= self.bounds.height / 2  + statusBarHeight {
                    self.center.y = self.bounds.height / 2 + statusBarHeight
                }
            }
        }
    }

    private func saveLocation() {
        let defaults = UserDefaults.standard
        defaults.set(self.center.x, forKey: (self.keyTag + Constants.keyCenterX))
        defaults.set(self.center.y, forKey: (self.keyTag + Constants.keyCenterY))
    }

    private func loadLocation() {
        let defaults = UserDefaults.standard

        let centerX = defaults.float(forKey: (self.keyTag + Constants.keyCenterX))
        let centerY = defaults.float(forKey: (self.keyTag + Constants.keyCenterY))

        print("(\(centerX), \(centerY))")

        if (centerX != 0 && centerY != 0) {
            self.center.x = CGFloat(centerX)
            self.center.y = CGFloat(centerY)
        }
    }
}
