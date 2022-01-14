//
//  ContentModel.swift
//  LearningApp
//
//  Created by Keegan Pangowish on 2021-12-26.
//

import Foundation

class ContentModel: ObservableObject {
    
    // List of Modules
    @Published var modules = [Module]()
    
    // Current module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    // Current Lesson
    @Published var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    //Current Question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    // Current lesson explanation
    @Published var codeText = NSAttributedString()
    
    var styleData: Data?
    
    // current selected content and test
    @Published var currentContentSelected: Int?
    @Published var currentTestSelected: Int?
    
    init() {
        
        // parse local included json data
        getLocalData()
        
        // download remote json and parse data
        getRemoteData()
        
    }
    
    // MARK: - data methods
    func getLocalData() {
        
        // get url to json file
        let jsonUrl = Bundle.main.url(forResource: "data", withExtension: "json")
        
        do {
            // read file into a data object
            let jsonData = try Data(contentsOf: jsonUrl!)
            
            //try to decode the json into an array of modules
            let jsonDecoder = JSONDecoder()
            let modules = try jsonDecoder.decode([Module].self, from: jsonData)
            
            // assign parsed modules to podules property
            self.modules = modules
        }
        catch {
            print("Couldn't parse local data")
        }
        
        
        //parse style data
        let styleUrl = Bundle.main.url(forResource: "style", withExtension: "html")
        
        do {
            
            // read the file into a data object
            let styleData = try Data(contentsOf: styleUrl!)
            
            self.styleData = styleData
            
        }
        catch {
            //log error
            print("couldnt parse style data")
        }
    }
    
    func getRemoteData() {
        
        // string path
        let urlString = "https://keegansixxx.github.io/learningapp-data/data2.json"
        
        // create url object
        let url = URL(string: urlString)
        
        guard url != nil else {
            // couldnt create url
            return
        }
        
        // create a URLRequest object
        let request = URLRequest(url: url!)
        
        // get the session and kcik off the task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            // check if theres an error
            guard error == nil else {
                // there was an error
                return
            }
            
            do {
                // create json decoder
                let decoder = JSONDecoder()
                
                // decode
                let modules = try decoder.decode([Module].self, from: data!)
                
                // append parsed module into modules property
                self.modules += modules
                
            }
            catch {
                // couldnt parse json
            }
        }
        
        // kick off data task
        dataTask.resume()
    }
    
    //MARK: - module navigation methods
    
    func beginModule(_ moduleid:Int) {
        
        // Find the index for this module id
        for index in 0..<modules.count {
            if modules[index].id == moduleid {
                
                // found matching module
                currentModuleIndex = index
                break
            }
        }
        
        // Set the current module
        currentModule = modules[currentModuleIndex]
    }
    
    func beginLesson (_ lessonIndex: Int) {
        
        // check that the lesson index is within range of module lessons
        if lessonIndex < currentModule!.content.lessons.count {
            
            currentLessonIndex = lessonIndex
        }
        else {
            currentLessonIndex = 0
        }
        
        // set the current lesson
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        codeText = addStyling(currentLesson!.explanation)
    }
    
    func nextLesson() {
        
        // advance the lesson index
        currentLessonIndex += 1
        
        // check that it is within range
        if currentLessonIndex < currentModule!.content.lessons.count {
            
            // set the current lesson property
            currentLesson = currentModule!.content.lessons[currentLessonIndex]
            codeText = addStyling(currentLesson!.explanation)
        }
        else {
            
            // reset the lesson state
            currentLessonIndex = 0
            currentLesson = nil
            
        }
    }
    
    func hasNextLesson() -> Bool {
        
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    func beginTest(_ moduleId:Int) {
        
        // set the current module
        beginModule(moduleId)
        
        // set the current question
        currentQuestionIndex = 0
        
        // if there are question set the current question to the first one
        if currentModule?.test.questions.count ?? 0 > 0 {
            
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            
            // set the question content
            codeText = addStyling(currentQuestion!.content)
        }
    }
    
    func nextQuestion() {
        
        // advance the question index
        currentQuestionIndex += 1
        
        // check that its within the range of question
        if currentQuestionIndex < currentModule!.test.questions.count {
            
            // set the current question
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStyling(currentQuestion!.content)
        }
        else {
            // if not then reset the properties
            currentQuestionIndex = 0
            currentQuestion = nil
            
        }
    }
    
    //MARK: - code styling
    
    private func addStyling(_ htmlString: String) -> NSAttributedString {
        
        var resultString = NSAttributedString()
        var data = Data()
        
        // add the styling data
        if styleData != nil {
            data.append(self.styleData!)
        }
        
        // add html data
        data.append(Data(htmlString.utf8))
        
        // convert to attributed string
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            
            resultString = attributedString
        }
        
        return resultString
    }
}
