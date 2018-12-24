//
//  AlumsViewController.swift
//  CCPPhoto
//
//  Created by 储诚鹏 on 2018/12/24.
//  Copyright © 2018 储诚鹏. All rights reserved.
//

import UIKit

final class AlumsViewController: UIViewController {

    @IBOutlet weak var listTable: UITableView!
    private var dataSource = [AlbumModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.register(UINib(nibName: "AlbumsCell", bundle: nil), forCellReuseIdentifier: "AlbumsCell")
        listTable.tableFooterView = UIView(frame: .zero)
        fetchData()
    }
    
    private func fetchData() {
        CCPPhoto.fetchAllAlbums(.image) { (albums) in
            self.dataSource = albums
            self.listTable.reloadData()
        }
    }
}

extension AlumsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumsCell") as! AlbumsCell
        let album = dataSource[indexPath.row]
        cell.setContents(album)
        return cell
    }    
}
