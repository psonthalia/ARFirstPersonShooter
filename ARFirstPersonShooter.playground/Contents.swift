//: A SceneKit and ARKit based Playground

import PlaygroundSupport
import SceneKit
import ARKit

class QISceneKitViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    let session = ARSession()
    var sceneView: ARSCNView!
    var hasPlacedSoldier = false
    var soldier: SCNNode?
    var characterNode: SCNNode?
    var characterOrientation: SCNNode?
    var cameraNode = SCNNode()

    override func loadView() {
        sceneView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal

        // set up scene view
        sceneView.setup()
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session = session
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                  ARSCNDebugOptions.showWorldOrigin/*,
                                  .showBoundingBoxes,
                                  .showWireframe,
                                  .showSkeletons,
                                  .showPhysicsShapes,
                                  .showCameras*/
                                ]
        
        sceneView.showsStatistics = true
        
        // Now we'll get messages when planes were detected...
        sceneView.session.delegate = self

        // default lighting
        sceneView.autoenablesDefaultLighting = true
        
        // a camera
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        soldier = soldierNode()
        characterNode = SCNNode()
        characterNode!.name = "character"
        characterNode!.simdPosition = float3(0.1, -0.2, 0)
        
        characterOrientation = SCNNode()
        characterNode!.addChildNode(characterOrientation!)
        characterOrientation!.addChildNode(soldier!)

        
        self.view = sceneView
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print(self.cameraNode.rotation)
        for anchor in anchors {
            if ( !hasPlacedSoldier ) {
                soldier?.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                sceneView.scene.rootNode.addChildNode(soldier!)
                DispatchQueue.main.async {
                    self.hasPlacedSoldier = true
                }
                soldier?.animationPlayer(forKey: "idle")?.play()
            } else {
                let friend = soldierNode()
                friend.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                guard let geometryNode = friend.childNode(withName: "soldier", recursively: true) else { return }
                
                geometryNode.geometry!.firstMaterial?.diffuse.intensity = 0.5
                
                sceneView.scene.rootNode.addChildNode(friend)
            }
        }
    }
    // An exercise for the reader: make the characters respond to the orientation of the camera and turn accordingly.
//    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        DispatchQueue.main.async {
//            // Rotate Max to face the camera?
//            self.cameraNode.frame.maxX
//            self.characterOrientation?.runAction(
//                SCNAction.rotateTo(x: self.cameraNode.frame.maxX, y: self.cameraNode.frame.maxY, z: 0.0, duration: 0.1, usesShortestUnitArc:true))
//        }
//    }


    func soldierNode() -> SCNNode {
        let soldierScene = SCNScene(named: "Art.scnassets/character/soldier.scn")!
        let soldier = soldierScene.rootNode.childNode(withName: "soldier", recursively: true)!
        soldier.scale = SCNVector3(x: 0.03, y: 0.03, z: 0.03)
        return soldier
    }
}


extension ARSCNView {
    
    func setup() {
        antialiasingMode = .multisampling4X
        automaticallyUpdatesLighting = false
        
        preferredFramesPerSecond = 60
        contentScaleFactor = 1.3
        
//        if let camera = pointOfView?.camera {
//            camera.wantsHDR = true
//            camera.wantsExposureAdaptation = true
//            camera.exposureOffset = -1
//            camera.minimumExposure = -1
//            camera.maximumExposure = 3
//        }
    }
}


PlaygroundPage.current.liveView = QISceneKitViewController()
PlaygroundPage.current.needsIndefiniteExecution = true
