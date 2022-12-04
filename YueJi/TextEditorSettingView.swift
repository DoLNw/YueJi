//
//  TextEditorSettingView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/30.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
struct TextEditorSettingView: View {
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @EnvironmentObject private var viewModel: ContentViewModel
    
    @AppStorage(StaticProperties.USERDEFAULTS_NEEDBACKIMAGE) private var needBackImage = false
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                
                
                if needBackImage {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            if let data = viewModel.backgroundImageData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width - 30, height: geo.size.height - 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 5, x: 5, y: 5)
                            } else {
                                Label("选择背景", systemImage: "photo.on.rectangle")
                            }
                        }
                        .onChange(of: selectedPhotoItem) { newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    viewModel.setBackgroundImage(data: data)
                                }
                            }
                        }
                }
                
                Toggle("自定义背景", isOn: $needBackImage)
                    .onChange(of: needBackImage) { newValue in
                        if !newValue {
                            viewModel.setBackgroundImage(data: nil)
                        }
                    }
                    .padding(30)
            }
            .padding([.top], 20)
        }
        
    }
}
