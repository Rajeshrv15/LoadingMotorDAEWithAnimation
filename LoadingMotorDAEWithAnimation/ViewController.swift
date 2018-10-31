//
//  ViewController.swift
//  LoadingMotorDAEWithAnimation
//
//  Created by Alpha on 30/10/18.
//  Copyright © 2018 SAG. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var _drillBitHolder : SCNNode?
    var anEngineNodes : [SCNNode] = [SCNNode]()
    var strArrayNodesToMove : [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        strArrayNodesToMove.append("group_40")
        strArrayNodesToMove.append("group_41")
        strArrayNodesToMove.append("group_42")
        strArrayNodesToMove.append("group_43")
        strArrayNodesToMove.append("group_1")
        strArrayNodesToMove.append("group_14")
        strArrayNodesToMove.append("group_7")
        
        
        //Get Tapgesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addTwinImageToScene(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func addTwinImageToScene(withGestureRecognizer recognizer: UIGestureRecognizer) {
        if _drillBitHolder != nil {
            return
        }
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        //print ("hittestresults func called")
        guard let hitTestResult = hitTestResults.first else {
            //print ("hittestresults else returned")
            return }
        let translation = hitTestResult.worldTransform.columns.3
        
        //DrillingMachingTwin.dae, model 2.dae
        guard let twinImgScene = SCNScene(named: "DTwins.scnassets/ElectricMotor.dae"),
         let shipNode = twinImgScene.rootNode.childNode(withName: "SketchUp", recursively: false)
         else {
            print("scene not found return")
            return
         }
        
        //anEngineNodes = twinImgScene.rootNode.childNodes
        sceneView.autoenablesDefaultLighting = false
        //Drill bit's holder rotation
        _drillBitHolder = twinImgScene.rootNode.childNode(withName: "SketchUp", recursively: false)!
        
        strArrayNodesToMove.forEach { item in
            print(item)
            guard let anSCNNode = twinImgScene.rootNode.childNode(withName: String(item), recursively: true)
                //print(anSCNNode)
            else { return }
            print(anSCNNode)
            anEngineNodes.append(anSCNNode)
        }
        
        print ("adding node here")
        //_drillBitHolder?.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        shipNode.position = SCNVector3(translation.x, translation.y, translation.z)
        sceneView.scene.rootNode.addChildNode(shipNode)
        setupAmbientLight()
        setupOmniDirectionalLight()
        
        //_drillBitHolder = twinImgScene.rootNode.childNode(withName: "group_0", recursively: true)!
        //let anloop = SCNAction.repeatForever(SCNAction.rotateBy(x: -5, y: 0, z: 0, duration: 5))
        /*let anloop = SCNAction.repeatForever(SCNAction.move(to: SCNVector3(-20, 0, 0), duration: 5))
        _drillBitHolder?.runAction(anloop)*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //1. Get The Current Touch Location
        guard let currentTouchLocation = touches.first?.location(in: self.sceneView) else { return }
        
        //2. Get The Results Of The SCNHitTest
        let hitTestResults = self.sceneView.hitTest(currentTouchLocation, options: nil)
        
        
        //3. Loop Through Them And Handle The Result
        for result in hitTestResults{
            
            print(result.node)
            print(result.node.name)
            
            var anSCNActions : [SCNAction] = [SCNAction]()
            
            let wait:SCNAction = SCNAction.wait(duration: 10)
            var iPosition = 5
            
            if result.node.name == "ID5" {
                print("I am here")
                var iPosActual = -40
                anEngineNodes.forEach { item in
                    /*print("Applying action on \(item)")
                    let anloopAction = SCNAction.customAction(duration: 3) { (node, elapsedTime) in
                        item.position.x = -20
                    }*/
                    //let anloop = SCNAction.repeatForever(SCNAction.move(to: SCNVector3(-20, 0, 0), duration: 3))
                    //let wait:SCNAction = SCNAction.wait(duration: 3)
                    //anSCNActions.append(anloopAction)
                    let anLoopAction = SCNAction.move(by: SCNVector3(iPosActual,0,0), duration: 5)
                    item.runAction(SCNAction.sequence([anLoopAction, wait]))
                    iPosActual = iPosActual + iPosition
                }
                
                //_drillBitHolder?.runAction(SCNAction.sequence(anSCNActions))
                /*let anloop = SCNAction.repeatForever(SCNAction.move(to: SCNVector3(-20, 0, 0), duration: 5))
                _drillBitHolder?.runAction(anloop)*/
                
                /*let anLoopAction = SCNAction.move(by: SCNVector3(-20,0,0), duration: 5)
                anEngineNodes[0].runAction(SCNAction.sequence([anLoopAction]))*/
            }
            //print(result.node.childNodes)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if _drillBitHolder != nil {
            return
        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.gray
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        //_ = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,0,z)
        planeNode.opacity = 0.15
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    private func setupAmbientLight() {
        
        // setup ambient light source
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor(white: 0.53, alpha: 1.0).cgColor
        
        // add to scene
        /*guard let scene = sceneView.scene else {
            
            return
        }*/
        sceneView.scene.rootNode.addChildNode(ambientLightNode)
    }
    
    private func setupOmniDirectionalLight() {
        
        // initialize noe
        let omniLightNode = SCNNode()
        // assign light
        omniLightNode.light = SCNLight()
        // set type
        omniLightNode.light!.type = SCNLight.LightType.omni
        // color and position
        omniLightNode.light!.color = UIColor(white: 0.56, alpha: 1.0).cgColor
        omniLightNode.position = SCNVector3Make(0.0, 2000.0, 0.0)
        
        // add to scene
        /*guard let scene = sceneView.scene else {
            
            return
        }*/
        sceneView.scene.rootNode.addChildNode(omniLightNode)
    }


    // MARK: - ARSCNViewDelegate
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
