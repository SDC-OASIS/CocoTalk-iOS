//
//  ChatRoomListViewController.swift
//  CocoTalk
//
//  Created by byunghak on 2022/01/18.
//

import UIKit
import SnapKit
import Then
import RxSwift

class ChatRoomListViewController: UIViewController {
    
    // MARK: - UI Properties
    /// 네비게이션 바
    private let gnbView = GNBView()
    
    private let tableView = UITableView()
    
    // MARK: - Properties
    var bag = DisposeBag()
    var viewModel = ChatRoomListViewModel()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.isNavigationBarHidden = true
        gnbView.setDelegate(delegate: self)
        
        configureView()
        configureSubviews()
        bindRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
    }
    
    // MARK: - Helper
    private func fetch() {
        viewModel.fetch()
    }
}

// MARK: - BaseViewController
extension ChatRoomListViewController {
    func configureView() {
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatRoomCell.self, forCellReuseIdentifier: ChatRoomCell.identifier)
        tableView.rowHeight = 76
        view.addSubview(tableView)
        view.addSubview(gnbView)
    }
    
    func configureSubviews() {
        gnbView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(gnbView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Bindable
extension ChatRoomListViewController {
    func bindRx() {
        viewModel.output.rooms
            .subscribe(onNext: { [weak self] rooms in
                guard let self = self else {
                    return
                }
                self.tableView.reloadData()
            }).disposed(by: bag)
    }
}


// MARK: - UITableViewDelegate, UITableViewDatasource
extension ChatRoomListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.rooms.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomCell.identifier, for: indexPath) as! ChatRoomCell
        cell.setData(data: viewModel.output.rooms.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatRoomViewController()
        vc.hidesBottomBarWhenPushed = true
        guard let nav = self.navigationController else {
            return
        }
        
        let backBarButtonItem = UIBarButtonItem(title: "350", style: .plain, target: self, action: nil)
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        nav.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ChatRoomListViewController: GNBDelegate {
    func gnbTabType() -> TabEnum {
        return .chatRoom
    }
    
    func tapAddChat() {
        
    }
    
    func tapSearch() {
        
    }
    
    func tapSetting() {
        
    }
}
