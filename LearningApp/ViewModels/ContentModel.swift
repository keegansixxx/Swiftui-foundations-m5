//
//  ContentModel.swift
//  LearningApp
//
//  Created by Keegan Pangowish on 2021-12-26.
//

import Foundation
import Firebase

class ContentModel: ObservableObject {
    
    let db = Firestore.firestore()
    
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
        getLocalStyles()
        
        // get database modules
        getModules()
        
        // download remote json and parse data
        //getRemoteData()
        
    }
    
    // MARK: - data methods
    
    func getLessons(module: Module, completion: @escaping () -> Void) {
        
        // specify path
        let collection = db.collection("modules").document(module.id).collection("lessons")
        
        // get documents
        collection.getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                
                // array to track lessons
                var lessons = [Lesson]()
                
                // loop through the documents and build array of lessons
                for doc in snapshot!.documents {
                    
                    // new lesson
                    var l = Lesson()
                    
                    l.id = doc["id"] as? String ?? UUID().uuidString
                    l.title = doc["title"] as? String ?? ""
                    l.video = doc["video"] as? String ?? ""
                    l.duration = doc["duration"] as? String ?? ""
                    l.explanation = doc["explanation"] as? String ?? ""
                    
                    // add lesson to the array
                    lessons.append(l)
                }
                
                // setting the lessons to the module
                // loop through published modules array and find the matching id that got passed in
                for (index, m) in self.modules.enumerated() {
                    
                    // find the module we want
                    if m.id == module.id {
                        
                        // set the lessons
                        self.modules[index].content.lessons = lessons
                        
                        // call the completion closure
                        completion()
                    }
                }
            }
        }
        
    }
    
    func getQuestions(module: Module, completion: @escaping () -> Void) {
        // specify path
        let collection = db.collection("modules").document(module.id).collection("questions")
        
        // get documents
        collection.getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                
                // array to track lessons
                var questions = [Question]()
                
                // loop through the documents and build array of lessons
                for doc in snapshot!.documents {
                    
                    // new lesson
                    var q = Question()
                    
                    q.id = doc["id"] as? String ?? UUID().uuidString
                    q.content = doc["content"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    q.answers = doc["answers"] as? [String] ?? [String]()
                    
                    // add lesson to the array
                    questions.append(q)
                }
                
                // setting the lessons to the module
                // loop through published modules array and find the matching id that got passed in
                for (index, m) in self.modules.enumerated() {
                    
                    // find the module we want
                    if m.id == module.id {
                        
                        // set the lessons
                        self.modules[index].test.questions = questions
                        
                        // call the completion closure
                        completion()
                    }
                }
            }
        }
    }
    
    func getModules() {
        
        // specify path
        let collection = db.collection("modules")
        
        // get documents
        collection.getDocuments { snapshot, error in
            
            // create an arrray for the modules
            var modules = [Module]()
            
            if error == nil && snapshot != nil {
                
                // loop through the documents returned
                for doc in snapshot!.documents {
                    
                    // create a new module instance
                    var m = Module()
                    
                    // parse out the values from the documents into the module instance
                    m.id = doc["id"] as? String ?? UUID().uuidString
                    m.category = doc["category"] as? String ?? ""
                    
                    // parse lesson content
                    let contentMap = doc["content"] as! [String: Any]
                    
                    m.content.id = contentMap["id"] as? String ?? ""
                    m.content.description = contentMap["description"] as? String ?? ""
                    m.content.image = contentMap["image"] as? String ?? ""
                    m.content.time = contentMap["time"] as? String ?? ""
                    
                    // parse test content
                    let testMap = doc["test"] as! [String: Any]
                    
                    m.test.id = testMap["id"] as? String ?? ""
                    m.test.description = testMap["description"] as? String ?? ""
                    m.test.image = testMap["image"] as? String ?? ""
                    m.test.time = testMap["time"] as? String ?? ""
                    
                    // add it to our array
                    modules.append(m)
                }
                
                // assign our modules to the published property
                DispatchQueue.main.async {
                    
                    self.modules = modules
                }
            }
        }
        
    }
    
    func getLocalStyles() {
        
//        // get url to json file
//        let jsonUrl = Bundle.main.url(forResource: "data", withExtension: "json")
//
//        do {
//            // read file into a data object
//            let jsonData = try Data(contentsOf: jsonUrl!)
//
//            //try to decode the json into an array of modules
//            let jsonDecoder = JSONDecoder()
//            let modules = try jsonDecoder.decode([Module].self, from: jsonData)
//
//            // assign parsed modules to podules property
//            self.modules = modules
//        }
//        catch {
//            print("Couldn't parse local data")
//        }
        
        
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
        
        // get the session and kick off the task
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
                
                DispatchQueue.main.async {
                    
                    // append parsed module into modules property
                    self.modules += modules
                    
                }
                
            }
            catch {
                // couldnt parse json
            }
        }
        
        // kick off data task
        dataTask.resume()
    }
    
    //MARK: - module navigation methods
    
    func beginModule(_ moduleid:String) {
        
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
        
        guard currentModule != nil else {
            return false
        }
        
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    func beginTest(_ moduleId:String) {
        
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
