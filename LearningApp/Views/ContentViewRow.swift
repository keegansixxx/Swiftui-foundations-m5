//
//  ContentViewRow.swift
//  LearningApp
//
//  Created by Keegan Pangowish on 2021-12-29.
//

import SwiftUI

struct ContentViewRow: View {
    
    @EnvironmentObject var model: ContentModel
    var index: Int
    
    var lesson: Lesson {
        
        if model.currentModule != nil && index < model.currentModule!.content.lessons.count {
            return model.currentModule!.content.lessons[index]
        }
        else {
            return Lesson(id: "", title: "", video: "", duration: "", explanation: "")
        }
    }
    
    var body: some View {
        
        let lesson = model.currentModule!.content.lessons[index]
        
        // lesson card
        ZStack(alignment: .leading) {
            
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(height: 66)
            
            HStack(spacing: 30.0) {
                
                Text(String(index+1))
                    .bold()
                
                VStack(alignment: .leading) {
                    
                    Text(lesson.title)
                        .bold()
                    
                    Text(lesson.duration)
                }
            }
            .padding()
        }
        .padding(.bottom, 2)
    }
}

struct ContentViewRow_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewRow(index: 1)
    }
}
