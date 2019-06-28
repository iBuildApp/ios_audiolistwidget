//
//  AudioListModule.swift
//  AudioListModule
//
//  Created by Anton Boyarkin on 25/06/2019.
//

import UIKit
import IBACore
import IBACoreUI

public class AudioListModule: BaseModule, ModuleType {
    public var moduleRouter: AnyRouter { return router }
    
    private var router: AudioListModuleRouter!
    internal var config: WidgetModel?
    internal var data: DataModel?
    
    public override class func canHandle(config: WidgetModel) -> Bool {
        return config.type == "audioplayer"
    }
    
    public required init() {
        print("\(type(of: self)).\(#function)")
        super.init()
        router = AudioListModuleRouter(with: self)
    }
    
    public func setConfig(_ model: WidgetModel) {
        self.config = model
        guard let data = model.data else { return }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted])
            let decoder = JSONDecoder()
            self.data = try decoder.decode(DataModel.self, from: jsonData)
        } catch {
            print(error)
        }
    }
}
