//
//  ContentView.swift
//  GridView
//
//  Created by Leandro Vitor on 04/01/21.
//

import SwiftUI
import Kingfisher

struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results: [Result]
}

struct Result: Decodable, Hashable {
    let copyright, name, artworkUrl100, releaseDate: String
}

class GridViewModel: ObservableObject {
    @Published var items = 0..<10
    @Published var results = [Result]()
    
    init() {
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/br/ios-apps/new-apps-we-love/all/100/explicit.json") else {return}
        URLSession.shared.dataTask(with: url) { data, resp, err in
            guard let data = data else {return}
            do {
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                self.results = rss.feed.results
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
    }
}

struct ContentView: View {
    
    @ObservedObject var vm = GridViewModel()
    @State var searchText:String = ""
    @State var isSearching:Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                HStack {
                    HStack {
                        TextField("Search", text: $searchText)
                            .padding(.leading, 24)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
                    .onTapGesture(perform: {
                        isSearching = true
                    })
                    .padding(.horizontal)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(Color.gray)
                            Spacer()
                            if(isSearching) {
                                Button(action: {
                                    searchText = ""
                                }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.gray)
                                        .padding(.vertical)
                                })
                            }
                        }
                        .padding(.horizontal, 32)
                    )
                    .transition(.move(edge: .trailing))
                    .animation(.spring())
                    
                    if(isSearching) {
                        Button(
                            action: {
                                isSearching = false
                                searchText = ""
                                
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                
                            }, label: {
                                Text("Cancel")
                                    .padding(.trailing)
                            })
                            .transition(.move(edge: .trailing))
                            .animation(.spring())
                    }
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16)
                ], alignment: .leading, spacing: 16,  content: {
                    ForEach((vm.results).filter({ "\($0)".contains(searchText) || searchText.isEmpty }), id:\.self) { app in
                        AppInfo(app: app)
                    }
                }).padding(.horizontal, 12)
            }.navigationTitle("Grid Search By Json")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AppInfo: View {
    let app: Result
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            
            KFImage(URL(string: app.artworkUrl100))
                .resizable()
                .scaledToFit()
                .cornerRadius(22)
            
            Text(app.name)
                .font(.system(size: 10, weight: .semibold))
                .padding(.top, 4)
            Text(app.releaseDate)
                .font(.system(size: 9, weight: .regular))
            Text(app.copyright)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(Color.gray)
            
            Spacer()
        }
    }
}
