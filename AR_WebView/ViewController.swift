//
//  ViewController.swift
//  AR_WebView
//
//  Created by sun on 11/5/2562 BE.
//  Copyright © 2562 sun. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
      //  let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
  //      sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            fatalError("Missing expected asset catalog resources")
        }
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = refImages
        configuration.maximumNumberOfTrackedImages = 1

        // Run the view's session
        sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: [.resetTracking, .removeExistingAnchors]))
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        
        let physicalWidth = imageAnchor.referenceImage.physicalSize.width
        let physicalHeight = imageAnchor.referenceImage.physicalSize.height
        
        let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight  )
        
        mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
        
        let mainNode = SCNNode(geometry: mainPlane)
        
        mainNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(mainNode)
        
        self.displayWebView(on: mainNode, xOffset: physicalWidth)
        
    }
    
    func displayWebView(on rootNode: SCNNode , xOffset: CGFloat){
        
        DispatchQueue.main.async {
            
            let request = URLRequest(url: URL(string: "https://www.worldwildlife.org/species/african-elephant#overview")!)
            
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 672))
            webView.loadRequest(request)
            
            let webViewPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
            webViewPlane.cornerRadius = 0.005
            
            let webViewNode = SCNNode(geometry: webViewPlane)
            
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
          //  webViewNode.position.z = -0.5
            
            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.sequence([
                .wait(duration: 3.0),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: xOffset * 1.1, y: 0, z: 0, duration: 1.5),
                .moveBy(x: 0, y: 0, z: 0, duration: 0.2)
                ])
            )
            
        }
        
        
    }

   
}
