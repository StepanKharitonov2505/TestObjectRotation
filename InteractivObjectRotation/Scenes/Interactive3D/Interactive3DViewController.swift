//
//  Interactive3DViewController.swift
//  InteractivObjectRotation
//
//  Created by  user on 10.09.2023.
//

import UIKit
import SceneKit
import SnapKit

// IN PROGRESS
final class Interactive3DViewController: UIViewController {
    
    /// 1) Refactoring
    
    // MARK: - Scene properties

    private var sceneView = SCNView(frame: .zero)
    private var scnScene: SCNScene!
    private var camera: SCNNode!
    private var ambientLight: SCNNode!
    private var spotLightBottomRight: SCNNode!
    private var spotLightBottomLeft: SCNNode!
    private var spotLightFront: SCNNode!
    private lazy var matrix: SCNMatrix4 = {
        var matrix = SCNMatrix4Identity
        return matrix
    }()
  
  // MARK: - PanGesture Recognize
  
    private let panGestureRecognizer = UIPanGestureRecognizer()
    private var panGestureAnchorPoint: CGPoint?
  
  // MARK: - Life cycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.rgb(30, 73, 101)

        sceneView.backgroundColor = .clear
        sceneView.isJitteringEnabled = true
        sceneView.antialiasingMode = .multisampling4X

        view.addSubview(sceneView)
        setupScene()
        setupSceneViewConstraint()
        setupCamera()
        setupLight()
        setupTargetToSceneView()
    }
  
  // MARK: - Private func
  
    private func setupScene() {
        scnScene = SCNScene(named: "SceneKitAssetCatalog.scnassets/SSLogoScnFormat.scn")

        let ssLogoNode = scnScene.rootNode.childNode(withName: "Cylinder", recursively: true)!
        ssLogoNode.position = SCNVector3(x: 0, y: 0, z: 0)
        ssLogoNode.eulerAngles = SCNVector3(
            x: GLKMathDegreesToRadians(0),
            y: GLKMathDegreesToRadians(0),
            z: GLKMathDegreesToRadians(0)
        )
        ssLogoNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        sceneView.scene = scnScene
    }
    
    private func setupCamera() {
        camera = SCNNode()
        camera.camera = SCNCamera()
        camera.eulerAngles = SCNVector3Make(
            GLKMathDegreesToRadians(-90),
            GLKMathDegreesToRadians(90),
            GLKMathDegreesToRadians(0)
        )
        camera.position = SCNVector3Make(0, 5, 0)
        camera.scale = SCNVector3Make(1, 1, 1)
        camera.camera?.usesOrthographicProjection = true
        camera.camera?.orthographicScale = 2.5

        sceneView.scene?.rootNode.addChildNode(camera)
        sceneView.pointOfView = camera
    }
  
    private func setupLight() {
        ambientLight = SCNNode()
        universalSetupLight(
            ambientLight,
            type: .ambient,
            parentSCView: sceneView
        )
        
        spotLightFront = SCNNode()
        universalSetupLight(
            spotLightFront,
            type: .ambient,
            position: SCNVector3Make(0, 0, 15),
            parentSCView: sceneView,
            lookAtTarget: scnScene.rootNode.childNode(withName: "Cylinder", recursively: true)
        )
        
        spotLightBottomRight = SCNNode()
        universalSetupLight(
            spotLightBottomRight,
            type: .spot,
            intensity: 1500,
            enableShadows: true,
            position: SCNVector3Make(5, -3, 1),
            parentSCView: sceneView,
            lookAtTarget: scnScene.rootNode.childNode(withName: "Cylinder", recursively: true)
        )

        spotLightBottomLeft = SCNNode()
        universalSetupLight(
            spotLightBottomLeft,
            type: .spot,
            intensity: 500,
            enableShadows: true,
            position: SCNVector3Make(-3, -3, 0.5),
            parentSCView: sceneView,
            lookAtTarget: scnScene.rootNode.childNode(withName: "Cylinder", recursively: true)
        )
    }
  
    private func universalSetupLight(_ lightNode: SCNNode,
                                   type: SCNLight.LightType,
                                   intensity: CGFloat = 1000,
                                   enableShadows: Bool = false,
                                   shadowRadius: CGFloat = 1,
                                   position: SCNVector3 = SCNVector3Make(0, 0, 0),
                                   eulerAngle: SCNVector3 = SCNVector3Make(
                                    GLKMathDegreesToRadians(0),
                                    GLKMathDegreesToRadians(0),
                                    GLKMathDegreesToRadians(0)
                                   ),
                                   scale: SCNVector3 = SCNVector3Make(1, 1, 1),
                                   parentSCView: SCNView,
                                   lookAtTarget: SCNNode? = nil
    ) {
        lightNode.light = SCNLight()
        lightNode.light?.type = type
        lightNode.light?.intensity = intensity
        lightNode.light?.castsShadow = enableShadows
        lightNode.light?.shadowMode = .forward
        lightNode.light?.shadowRadius = shadowRadius
        lightNode.position = position
        lightNode.eulerAngles = eulerAngle
        lightNode.scale = scale
        if lookAtTarget != nil {
            lightNode.constraints = [SCNLookAtConstraint(target: lookAtTarget)]
        }
        parentSCView.scene?.rootNode.addChildNode(lightNode)
    }
  
    private func refreshNode(duration: Double, node: SCNNode) {
        let identityMatrix = SCNMatrix4Identity

        let springAnimation = CASpringAnimation(keyPath: "transform")
        springAnimation.fromValue = node.transform
        springAnimation.toValue = identityMatrix
        springAnimation.damping = 6
        springAnimation.initialVelocity = 0.3
        springAnimation.fillMode = .forwards
        springAnimation.isRemovedOnCompletion = false
        springAnimation.duration = duration
        springAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        node.addAnimation(springAnimation, forKey: "transform")
    }
  
  // MARK: - Constraints
  
    private func setupSceneViewConstraint() {
        sceneView.snp.makeConstraints { cstr in
            cstr.center.equalTo(view.snp.center)
            cstr.left.equalTo(view.snp.left)
            cstr.right.equalTo(view.snp.right)
            cstr.height.equalTo(view.snp.height).multipliedBy(0.3)
        }
    }
  
  // MARK: - Setup Target
  
    private func setupTargetToSceneView() {
        panGestureRecognizer.addTarget(self, action:  #selector(handlePanGesture(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
}

// MARK: - PanGesture Recognize Method

private extension Interactive3DViewController {
    @objc
    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard panGestureRecognizer === gestureRecognizer else { assert(false); return }
        let ssLogoNode = sceneView.scene!.rootNode.childNode(
            withName: "Cylinder",
            recursively: true
        )
          
        switch gestureRecognizer.state {
        case .began:
            matrix = ssLogoNode!.presentation.transform
            assert(panGestureAnchorPoint == nil)
            panGestureAnchorPoint = gestureRecognizer.location(in: sceneView)
           
        case .changed:
            ssLogoNode?.removeAllAnimations()

            guard let panGestureLocation = panGestureAnchorPoint else { assert(false); return }
            let gesturePoint = gestureRecognizer.location(in: sceneView)
              
            let ratioMovementXToHalfWidthScreen = (gesturePoint.x - panGestureLocation.x) / (sceneView.bounds.width / 2)
            let angleX: Float = ( -.pi / 2 ) * Float(ratioMovementXToHalfWidthScreen)
            let rotate3dX = SCNMatrix4Rotate(
                matrix,
                angleX,
                1, 0, 0
            )
            
            let ratioMovementYToHalfHeightScreen = (gesturePoint.y - panGestureLocation.y) / (sceneView.bounds.height / 2)
            let angleY: Float = ( -.pi / 4 ) * Float(ratioMovementYToHalfHeightScreen)
            let rotate3dY = SCNMatrix4Rotate(
                matrix,
                angleY,
                0, 0, 1
            )
            
            ssLogoNode!.transform = SCNMatrix4Mult(rotate3dX, rotate3dY)
           
        case .cancelled, .ended:
            refreshNode(duration: 1.5, node: ssLogoNode!)
            panGestureAnchorPoint = nil
          
        case .failed, .possible:
            assert(panGestureAnchorPoint == nil)
            break
          
        @unknown default:
            break
        }
    }
}
