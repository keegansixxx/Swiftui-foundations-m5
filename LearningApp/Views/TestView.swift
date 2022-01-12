//
//  TestView.swift
//  LearningApp
//
//  Created by Keegan Pangowish on 2022-01-11.
//

import SwiftUI

struct TestView: View {
    
    @EnvironmentObject var model: ContentModel
    @State var selectedAnswerIndex: Int?
    @State var submitted = false
    @State var numCorrect = 0
    
    var body: some View {
        
        if model.currentQuestion != nil {
            
            VStack(alignment: .leading) {
                
                // Quesiton number
                Text("Question \(model.currentQuestionIndex + 1) of \(model.currentModule?.test.questions.count ?? 0)")
                    .padding(.leading)
                
                
                // Question
                CodeTextView()
                    .padding(.horizontal)
                
                // Answers
                ScrollView {
                    
                    VStack {
                        
                        ForEach(0..<model.currentQuestion!.answers.count, id: \.self) { index in
                            
                            Button {
                                // Track the selected index
                                selectedAnswerIndex = index
                            } label: {
                                
                                ZStack {
                                    
                                    if submitted == false {
                                    RectangleCard(color: index==selectedAnswerIndex ? .gray : .white)
                                        .frame(height: 48)
                                    }
                                    else {
                                        // answer has been submitted
                                        if index == selectedAnswerIndex &&
                                            index == model.currentQuestion!.correctIndex {
                                            
                                            //user has selected the right answer
                                            // show green background
                                            RectangleCard(color: .green)
                                                .frame(height: 48)
                                            
                                        }
                                        else if index == selectedAnswerIndex &&
                                                    index != model.currentQuestion!.correctIndex {
                                            
                                            // user has selected wrong answer
                                            // show red background
                                            RectangleCard(color: .red)
                                                .frame(height: 48)
                                        }
                                        else if index == model.currentQuestion!.correctIndex {
                                            
                                            // this button is the correct answer
                                            // show a green background
                                            RectangleCard(color: .green)
                                                .frame(height: 48)
                                        }
                                        else {
                                            RectangleCard(color: .white)
                                                .frame(height: 48)
                                        }
                                    }
                                    
                                    Text(model.currentQuestion!.answers[index])
                                    
                                }
                            }
                            .disabled(submitted)
                        }
                    }
                    .accentColor(.black)
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                }
                
                // Submit Button
                Button {
                    
                    // change submitted state to true
                    submitted = true
                    
                    // check the answer and increment the counter if correct
                    if selectedAnswerIndex == model.currentQuestion!.correctIndex {
                        numCorrect += 1
                    }
                } label: {
                    ZStack {
                        
                        RectangleCard(color: .green)
                            .frame(height: 48)
                        
                        Text("Submit")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                }
                .disabled(selectedAnswerIndex == nil)

            }
            .navigationBarTitle("\(model.currentModule?.category ?? "") Test")
        }
        else {
            
            // test hasn't loaded yet
            ProgressView()
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
