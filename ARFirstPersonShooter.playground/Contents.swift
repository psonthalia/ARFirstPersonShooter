//: A SceneKit and ARKit based Playground

import PlaygroundSupport
import SceneKit
import ARKit

class QISceneKitViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    let session = ARSession()
    var sceneView: ARSCNView!
    var cameraNode = SCNNode()
    
    var numberOfSoldiers = 5;
    var soldiersPlacedCount = 0;
    var soldierArray: [SCNNode?] = []

    override func loadView() {
        sceneView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal

        sceneView.setup()
        sceneView.delegate = self
        sceneView.session = session
        sceneView.showsStatistics = true
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        
        self.view = sceneView
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if (soldiersPlacedCount < numberOfSoldiers) {
                let soldier = soldierNode()
                soldier.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                
                soldierArray.append(soldier)
                soldiersPlacedCount += 1
                sceneView.scene.rootNode.addChildNode(soldier)
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
    }
}


PlaygroundPage.current.liveView = QISceneKitViewController()
PlaygroundPage.current.needsIndefiniteExecution = true
