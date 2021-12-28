//
//  ContentModel.swift
//  LearningApp
//
//  Created by Keegan Pangowish on 2021-12-26.
//

import Foundation

class ContentModel: ObservableObject {
    
    @Published var modules = [Module]()
    
    var styleData: Data?
    
    init() {
        
        getLocalData()
        
    }
    
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
    
}
