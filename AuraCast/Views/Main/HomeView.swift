//
//  HomeView.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 10/06/2026.
//

import SwiftUI

struct HomeView: View {
    
    
    var body: some View {
        
        NavigationView {
            ZStack{
                //MARK: Background Color
                Color.background
                    .ignoresSafeArea()
                
                //MARK: Background Image
                Image("Background")
                      .resizable()
                      .ignoresSafeArea()
                
                //MARK: House Image
                Image("House")
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top,257)
            
                VStack(spacing:-10){
                    Text("Cairo")
                        .font(.largeTitle)
                    
                    VStack{
                        Text(attributedString)
                    }
                    
                    Spacer()
                }.padding(.top,51)
                
                //MARK: TabBar
                TabBar(action: {})
            }.navigationBarHidden(true)
        }
    }
    
    
    private var attributedString:AttributedString {
        var string = AttributedString("19°"+"\n"+"Mostly Clear")
        
        if let temp = string.range(of: "19°"){
            string[temp].font = .system(size: 96,weight:.thin)
            string[temp].foregroundColor = .primary
        }
        
        if let pipe = string.range(of: " | "){
            string[pipe].font = .title3.weight(.semibold)
            string[pipe].foregroundColor = .secondary
        }
        
        if let weather = string.range(of: "Mostly Clear"){
            string[weather].font = .title3.weight(.semibold)
            string[weather].foregroundColor = .secondary
        }
        
        return string
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewInterfaceOrientation(.portrait)
            .preferredColorScheme(.dark)
    }
}
