//
//  AudioListModuleRouter.swift
//  AudioListModule
//
//  Created by Anton Boyarkin on 25/06/2019.
//

import IBACore
import IBACoreUI

public enum AudioListModuleRoute: Route {
    case root
}

public class AudioListModuleRouter: BaseRouter<AudioListModuleRoute> {
    var module: AudioListModule?
    init(with module: AudioListModule) {
        self.module = module
    }

    public override func generateRootViewController() -> BaseViewControllerType {
        return AudioListViewController(type: module?.config?.type, data: module?.data)
    }

    public override func prepareTransition(for route: AudioListModuleRoute) -> RouteTransition {
        return RouteTransition(module: generateRootViewController(), isAnimated: true, showNavigationBar: true, showTabBar: false)
    }

    public override func rootTransition() -> RouteTransition {
        return self.prepareTransition(for: .root)
    }
}
