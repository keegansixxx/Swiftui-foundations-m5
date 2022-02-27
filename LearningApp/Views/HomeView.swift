//
//  HomeView.swift
//  LearningApp
//
//  Created by Keegan Pangowish on 2021-12-26.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading) {
                
                Text("What do you want to do today?")
                    .padding(.leading, 20)
                
                ScrollView {
                    
                    LazyVStack {
                        
                        ForEach(model.modules) { module in
                            
                            VStack(spacing: 20.0) {
                                
                                NavigationLink(destination:
                                                ContentView()
                                                .onDisappear{print("testing")}
                                                .onAppear(perform: {
                                    model.getLessons(module: module) {
                                        model.beginModule(module.id)
                                    }
                                    
                                }),
                                               tag: module.id.hash,
                                               selection: $model.currentContentSelected, label: {
                                    
                                    // Learning Card
                                    HomeViewRow(image: module.content.image, title: "Learn \(module.category)", description: module.content.description, count: "\(module.content.lessons.count) Lessons", time: module.content.time)})
                                
                                NavigationLink(destination: TestView()
                                                .onAppear(perform: {
                                    model.getQuestions(module: module) {
                                        model.beginTest(module.id)
                                    }
                                }), tag: module.id.hash, selection: $model.currentTestSelected) {
                                    
                                    //Test Card
                                    HomeViewRow(image: module.test.image, title: "\(module.category) Test", description: module.test.description, count: "\(module.test.questions.count) Questions", time: module.test.time)
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .accentColor(.black)
                    .padding()
                }
            }
            .navigationTitle("Get Started")
            .onChange(of: model.currentContentSelected) { changedValue in
                if changedValue == nil {
                    model.currentModule = nil
                }
            }
            .onChange(of: model.currentTestSelected) { changedValue in
                if changedValue == nil {
                    model.currentModule = nil
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ContentModel())
    }
}
