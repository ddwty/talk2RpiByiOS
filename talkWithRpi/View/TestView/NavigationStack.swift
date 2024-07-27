//
//  NavigationStack.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/27/24.
//

import SwiftUI

struct MyNavigationStack: View {
    let fruits = ["aaaa", "bvvv", "cfa"]
    
    @State var path: [String] = []
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 20) {
                    Button("hahaha") {
                        path.append("hefdhf")
                    }
                    ForEach(fruits, id:\.self) {fruit in
                        NavigationLink(value: fruit) {
                            Text(fruit)
                        }
                    }
                }
            }
            .navigationTitle("hahah")
            .navigationDestination(for: String.self) { value in
                Text("babab\(value)")
            }
        }
    }
}

#Preview {
    MyNavigationStack()
}
