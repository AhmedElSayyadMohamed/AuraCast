//
//  TabBar.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 10/06/2026.
//

import SwiftUI

struct TabBar: View {
    
    var action:()-> Void
    var body: some View {

        ZStack{

            HStack{
                Button {
                    action()
                } label: {
                    
                    Image(systemName: "mappin.and.ellipse")
                        .frame(width: 44, height: 44)
                    
                    Spacer()
                    
                    NavigationLink{
                        
                        
                    } label:{
                        Image(systemName: "list.star")
                            .frame(width: 44, height: 44)
                    }
                }
                
            }
            .font(.title3)
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 20, leading: 32, bottom: 24, trailing: 32))
        }
        .frame(maxHeight:.infinity , alignment: .bottom)
        .ignoresSafeArea()
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(action: {
            print("Tab pressed!")
        })
            .preferredColorScheme(.dark)
    }
}
