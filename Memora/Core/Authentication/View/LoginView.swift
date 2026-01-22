//
//  LoginView.swift
//  Memora
//
//  Created by Eylül Soylu on 22.01.2026.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel : AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack{
            
            VStack{
                // image
                Image(colorScheme == .dark ? "notivoDark" : "notivo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400,height: 250)
                    .padding(.bottom,50)
                   
                
                //form fields
                VStack(spacing:25){
                    InputView(text:$email,
                              title:"Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    InputView(text:$password,
                              title:"Password",
                              placeholder: "Enter your password",
            
                              isSecureField: true)
                    
                    
                }
                .padding(.horizontal)
                .padding(.top,12)
                
                // sign in button
                
                
                Button{
                Task{
                    try await  viewModel.signIn(withEmail: email, password: password)
                    }
                } label:{
                    HStack{
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 45,height: 38)
                }
                .background(Color(.systemPurple))
                .disabled(!formIsValid) // koşulu atar
                .opacity(formIsValid ? 1 : 0.5) // koşul sağlanmadığı takdirde sign in butonu saydam olur
                .cornerRadius(32)
                .padding(.top,40)
                
                
                Spacer()
                
                //sign up button
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                        .environmentObject(viewModel)
                       
                        
                } label: {
                    HStack(spacing:10){
                        Text("Don't have an account?")
                            .foregroundColor(Color(.systemPurple))
                        Text("Sign up")
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemPurple))
                            
                            
                    }
                    .font(.system(size:14))
                    
                }

           
            }
            
        
        }
    }
}


extension LoginView: AuthenticationFormProtocol{ // emailde @ işareti girilmediğinde, email boş olduğunda, password 5 karakterden kısa olduğunda ve password boş oduğunda koşulunu sign in butonuna atar
    var formIsValid: Bool {
    return !email.isEmpty
        && email.contains( "@" )
        && !password.isEmpty
        && password.count > 5
    }
    
    
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
