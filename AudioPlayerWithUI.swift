//
//  TestSwiftUIView.swift
//  Melodious
//
//  Created by 王天伟 on 2020/9/16.
//  Copyright © 2020 王天伟. All rights reserved.
//

import SwiftUI
import AVKit

struct AudioPlayerWithUI: View {
    @State var data:Data = .init(count:0)
    //    当前播放音频标题
    @State var title = ""
    //    声明播放工具
    @State var player : AVAudioPlayer!
    //    是否正在播放
    @State var playing = false
    //    播放进度条进度（宽度）
    @State var width:CGFloat = 0
    //    播放音频列表
    @State var songs = ["test","test1"]
    //    当前播放音频在列表中的位置
    @State var current = 0
    //    是否播放完成
    @State var finish = false
    @State var del = AVdelegate()

    var body: some View {
        VStack(spacing:20){
            Image(uiImage: self.data.count == 0 ? UIImage(named: "test")! : UIImage(data: self.data)!).resizable().frame(width: self.data.count == 0 ? 250 : nil, height: 250).cornerRadius(15)
            Text(self.title).font(.title).padding(.top)
            ZStack(alignment: .leading){
                Capsule().fill(Color.black.opacity(0.88)).frame(height:9)
                Capsule().fill(Color.red).frame(width:self.width, height:8).gesture(DragGesture().onChanged({ (value) in
                    let x = value.location.x
                    self.width = x
                }).onEnded({ (value) in
                    let x = value.location.x
                    let screen = UIScreen.main.bounds.width - 30
                    let percent = x / screen
                    self.player.currentTime = Double(percent) * self.player.duration
                })
                )
            }.padding(.top)
            HStack(spacing:UIScreen.main.bounds.width / 5 - 30){
                Button(action: {
                    if self.current > 0 {
                        self.current -= 1
                        self.ChangeSongs()
                    }

                }) {
                    Image(systemName: "backward.fill").font(.title)
                }
                Button(action: {
                    self.player.currentTime -= 15
                }) {
                    Image(systemName: "gobackward.15").font(.title)
                }
                Button(action: {
                    if self.player.isPlaying{
                        self.player.pause()
                        self.playing=false
                    }else{

                        if self.finish {
                            self.player.currentTime = 0
                            self.width = 0
                            self.finish = false
                        }

                        self.player.play()
                        self.playing=true
                    }
                }) {
                    Image(systemName: self.playing && !self.finish ? "pause.fill" : "play.fill").font(.title)
                }
                Button(action: {
                    let increase = self.player.currentTime + 15
                    if increase < self.player.duration{
                        self.player.currentTime = increase
                    }
                }) {
                    Image(systemName: "goforward.15").font(.title)
                }
                Button(action: {
                    if self.songs.count - 1 != self.current {
                        self.current += 1
                        self.ChangeSongs()
                    }
                }) {
                    Image(systemName: "forward.fill").font(.title)
                }
            }.padding(.top,25).foregroundColor(.black)
        }.padding()
        .onAppear(){
            let url = Bundle.main.path(forResource: self.songs[self.current], ofType: "mp3")
            self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))

            self.player.delegate = self.del

            self.player.prepareToPlay()
            self.getData()
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true){
                (_) in
                if self.player.isPlaying{
                    print(self.player.currentTime)
                    let screen = UIScreen.main.bounds.width - 30
                    let value = self.player.currentTime / self.player.duration
                    self.width = screen * CGFloat(value)

                }
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main){(_) in

                self.finish = true

            }
        }
    }

    func getData(){

        let asset = AVAsset(url: self.player.url!)

        for i in asset.commonMetadata {
            if i.commonKey?.rawValue == "artwork" {
                let data = i.value as! Data
                self.data = data
            }

            if i.commonKey?.rawValue == "title" {
                let title = i.value as! String
                self.title = title
            }
        }
    }

    func ChangeSongs(){
        let url = Bundle.main.path(forResource: self.songs[self.current], ofType: "mp3")
        self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))



        self.data = .init(count: 0)
        self.title = ""

        self.player.prepareToPlay()
        self.getData()

        self.playing = true

        self.finish = false

        self.width = 0

        self.player.play()
    }

}

struct AudioPlayerWithUI_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerWithUI()
    }
}

class AVdelegate : NSObject,AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
    }
}
