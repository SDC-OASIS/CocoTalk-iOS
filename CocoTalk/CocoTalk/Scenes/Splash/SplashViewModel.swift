//
//  SplashViewModel.swift
//  CocoTalk
//
//  Created by byunghak on 2022/02/08.
//

import Foundation
import RxSwift
import RxRelay
import SwiftKeychainWrapper

protocol SplashInput {
    
}

protocol SplashDependency {
    var isValidToken: BehaviorRelay<Bool?> { get }
    var isReissueSuccess: BehaviorRelay<Bool?> { get }
    var shouldSignout: BehaviorRelay<Bool?> { get }
    var isSignedIn: Bool { get }
}

protocol SplashOutput {
    
}

class SplashViewModel {
    
    var authRepository = AuthRepository()
    var bag = DisposeBag()
    var input = Input()
    var dependency = Dependency()
    var output = Output()
    
    struct Input: SplashInput {
        
    }
    
    struct Dependency: SplashDependency {
        var isValidToken = BehaviorRelay<Bool?>(value: nil)
        var isReissueSuccess = BehaviorRelay<Bool?>(value: nil)
        var shouldSignout = BehaviorRelay<Bool?>(value: nil)
        var isSignedIn: Bool {
            get {
                let token: String? = KeychainWrapper.standard[.accessToken]
                return token != nil
            }
        }
    }
    
    struct Output: SplashOutput {
        
    }
}


extension SplashViewModel {
    func verifyToken() {
        let token: String? = KeychainWrapper.standard[.accessToken]
        guard let token = token else {
            return
        }
        authRepository.verifyToken(token)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else {
                    return
                }
                
                guard let isSuccess = response.isSuccess,
                      isSuccess,
                      let _ = response.result else {
                          self.dependency.isValidToken.accept(false)
                          return
                      }
                
                self.dependency.isValidToken.accept(true)
            }).disposed(by: bag)
    }
    
    func reissueToken() {
        let token: String? = KeychainWrapper.standard[.refreshToken]
        guard let token = token else {
            return
        }
        authRepository.reissueToken(token)
            .subscribe(onNext: { [weak self] response in
                guard let self = self,
                      let result = response.result,
                      let accessToken = result.accessToken,
                      let refreshToken = result.refreshToken else {
                          self?.dependency.shouldSignout.accept(true)
                          return
                      }
                
                KeychainWrapper.standard[.accessToken] = accessToken
                KeychainWrapper.standard[.refreshToken] = refreshToken
                self.dependency.shouldSignout.accept(false)
            }).disposed(by: bag)
    }
}
