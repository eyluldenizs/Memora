//
//  RegistrationView.swift
//  Notivo
//
//  Created by Eylül Soylu on 27.09.2025.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel:AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack{
            Image(colorScheme == .dark ? "notivoDark" : "notivo")
                .resizable()
                .scaledToFit()
                .frame(width: 400,height: 250)
                .padding(.bottom,1)
               
            
            
            VStack(spacing:25){
                InputView(text:$email,
                          title:"Email Address",
                          placeholder: "name@example.com")
                .autocapitalization(.none)
                
                InputView(text:$fullname,
                          title:"Full Name",
                          placeholder: "Enter your name")
               
                
                InputView(text:$password,
                          title:"Password",
                          placeholder: "Enter your password",
        
                        isSecureField: true)
        
                ZStack(alignment:.trailing) {
                    InputView(text:$confirmPassword,
                              title:"Confirm password",
                              placeholder: "Confirm your password",
            
                            isSecureField: true)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {//passwordlar aynıysa yeşil check mark
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.medium)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")//farklıysa kırmızı çarpı
                                .imageScale(.medium)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
                
            }
            .padding(.horizontal)
            .padding(.top,40)
            
            Button{
                Task{
                    try await viewModel.createUser(withEmail: email, password: password, fullname: fullname)
                    await viewModel.fetchUser()
                }
            } label:{
                HStack{
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 39, maxHeight: 39)

            }
            .background(Color(.systemPurple))
            .disabled(!formIsValid) // koşulu atar
            .opacity(formIsValid ? 1 : 0.5) // koşul sağlanmadığı takdirde sign in butonu saydam olur
            .cornerRadius(32)
            .padding(.top,40)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing:10){
                    Text("Already have an account?")
                        .foregroundColor(Color(.systemPurple))
                    Text("Sign in")
                        .fontWeight(.bold)
                        .foregroundColor(Color(.systemPurple))
                        
                }
                .font(.system(size:14))
                
                
            }

        }
        
    }
}

extension RegistrationView: AuthenticationFormProtocol{ // emailde @ işareti girilmediğinde, email boş olduğunda, password 5 karakterden kısa olduğunda ve password boş oduğunda koşulunu sign in butonuna atar
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains( "@" )
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
    }
    
}


#Preview {
    RegistrationView()
        
}
