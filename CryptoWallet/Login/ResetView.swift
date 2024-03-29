//
//  ResetView.swift
//  Crypto
//
//  Created by CJ on 7/7/23.
//

import SwiftUI

/// A enum representing alert options for the 'ResetView' and 'SignUpView'
enum AlertOption {
    case failure(String)
    case success
}

/// A view representing the reset screen.
struct ResetView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var resetTask: Task<(), Never>?
    @State private var showAlert = false
    @State private var alertOption: AlertOption = .success
    @State private var countdown = 30
    @State private var isButtonEnabled = true
    @State private var timer: Timer?
    @FocusState private var focusedField: Field?
    
    private var alertTitle: String {
        switch alertOption {
        case .success: return "Sent successfully"
        case .failure: return "Failed to send"
        }
    }
    
    private var alertMessage: String {
        switch alertOption {
        case .success: return "A password reset email has been sent to your email."
        case .failure(let message): return message
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            titleSection
            mainSection
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.accent.gradient)
        .alert(alertTitle, isPresented: $showAlert) {
            switch alertOption {
            case .success:
                Button("OK") {
                    startTimer()
                }
            case .failure(_):
                Button("OK") {}
            }
        } message: {
            Text(alertMessage)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { dismissButton }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .onSubmit(executeResetTask)
        .onDisappear {
            resetTask?.cancel()
            timer?.invalidate()
        }
    }
  
    private var dismissButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .foregroundStyle(.white)
        .padding()
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading) {
            Text("Reset Password")
                .font(.largeTitle.bold())
                Text("Let's start by entering your email address.")
        }
        .foregroundStyle(.white)
        .shadow(radius: 5)
        .padding(.leading)
    }
    
    private var mainSection: some View {
        VStack(spacing: 40) {
            TextField("Email", text: $email)
                .textFieldStyle(.underline)
                .focused($focusedField, equals: .username)
                .keyboardType(.emailAddress)
            resetButton
        }
        .roundedCard()
    }
    
    private var resetButton: some View {
        PrimaryButton(text: isButtonEnabled ? "Send Instructions" : "Send Again (\(countdown)S)", action: executeResetTask)
            .disabled(!isButtonEnabled)
    }
    
    private func executeResetTask() {
        resetTask?.cancel()
        resetTask = Task {
            do {
                try validation()
                if try await authService.resetPassword(with: email) {
                    alertOption = .success
                    focusedField = nil
                }
            } catch {
                alertOption = .failure(error.localizedDescription)
                focusedField = .username
            }
            showAlert.toggle()
        }
    }
    
    private func validation() throws {
        if email.isEmpty || !email.isValidRegex(.email) {
            focusedField = .username
            throw AuthError.invalidEmail
        }
    }
    
    private func startTimer() {
        isButtonEnabled = false
        countdown = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
                timer = nil
                isButtonEnabled = true
            }
        }
    }
}
