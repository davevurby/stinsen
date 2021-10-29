import Foundation
import SwiftUI

struct TabCoordinatableView<T: TabCoordinatable, U: View>: View {
    private var coordinator: T
    private let router: TabRouter<T>
    @ObservedObject var child: TabChild
    private var customize: (AnyView) -> U
    private var views: [AnyView]
    
    var body: some View {
        TabView(selection: $child.activeTab) {
            ForEach(Array(views.enumerated()), id: \.offset) { view in
                customize(view)
                    .element
                    .tabItem {
                        coordinator.child.allItems[view.offset].tabItem(view.offset == child.activeTab)
                    }
                    .tag(view.offset)
            }
        }
        .environmentObject(router)
    }
    
    init(paths: [AnyKeyPath], coordinator: T, customize: @escaping (AnyView) -> U) {
        self.coordinator = coordinator
        
        self.router = TabRouter(coordinator: coordinator.routerStorable)
        RouterStore.shared.store(router: router)
        self.customize = customize
        self.child = coordinator.child
        
        if coordinator.child.allItems == nil {
            coordinator.setupAllTabs()
        }

        self.views = coordinator.child.allItems.map {
            $0.presentable.view()
        }
    }
}
