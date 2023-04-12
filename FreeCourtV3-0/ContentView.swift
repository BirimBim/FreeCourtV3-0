//
//  ContentView.swift
//  FreeCourtV3-0
//
//  Created by Bruno Luciano Soterio Ramalho on 2023-03-23.
//

import SwiftUI

struct ContentView: View {
    @State private var isWorkOutTime: Bool = false
    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            AllOnScreen(isWorkoutTime: $isWorkOutTime)
            TestButton(isWorkoutTime: $isWorkOutTime)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AllOnScreen: View{
    @Binding var isWorkoutTime: Bool
    @State public var minutesOcupied: Int = 0 // add a state variable to track minutes occupied
    var body: some View{
        
        let sizeText: CGFloat = isWorkoutTime ? 40 : 70
        VStack{
            Text(isWorkoutTime ? "             TEMPS D'ENTRAÎNEMENT" : "Occupé")
                .font(.system(size: sizeText, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
            Text(isWorkoutTime ? "" : "Depuis: \(minutesOcupied)min")
                .font(.system(size: 25, weight: .heavy))
                .foregroundColor(.white)
            Image(isWorkoutTime ? "basketball-court" : "basketball-2")
                .resizable()
                .scaledToFit()
                .frame(width: 350)
            
        }.padding(.bottom, 50)
        .task { // add a task that updates minutes occupied
            do {
                let data = try await GetPirData()
                minutesOcupied = data[1] // set minutes occupied to the latest value
                print(data)
            } catch {
                print("An error occurred: \(error)")
            }
        }
    }
}


struct TestButton: View{
    @Binding var isWorkoutTime: Bool
    
    var body: some View{
        Button{
            isWorkoutTime.toggle()
            
        }label: {
            Text("test")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.white)
                
        }.padding(.top, 500)
    }
}

//ServerSide
struct PirData: Codable {
    let feeds: [field1]
}

struct field1: Codable {
    let field1: String
}

// Define the updated function that retrieves data from the Thingspeak API
func GetPirData() async throws -> [Int] {
    let url = URL(string: "https://api.thingspeak.com/channels/2078356/feeds.json?api_key=4VLTJBQIY48ATLNR&results=2")!
    let (data, _) = try await URLSession.shared.data(from: url)
    
    let decoded = try JSONDecoder().decode(PirData.self, from: data)
    return decoded.feeds.map { Int($0.field1) ?? 500 }
}

