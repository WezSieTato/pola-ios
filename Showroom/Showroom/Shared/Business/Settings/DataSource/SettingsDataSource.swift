import UIKit

class SettingsDataSource: NSObject, UITableViewDataSource {
    
    private weak var tableView: UITableView?
    
    private(set) var settings = [Setting]()
    
    init(tableView: UITableView) {
        
        super.init()
        
        self.tableView = tableView
        self.tableView!.registerClass(SettingsHeaderCell.self, forCellReuseIdentifier: String(SettingsHeaderCell))
        self.tableView!.registerClass(SettingsLoginCell.self, forCellReuseIdentifier: String(SettingsLoginCell))
        self.tableView!.registerClass(SettingsLogoutCell.self, forCellReuseIdentifier: String(SettingsLogoutCell))
        self.tableView!.registerClass(SettingsGenderCell.self, forCellReuseIdentifier: String(SettingsGenderCell))
        self.tableView!.registerClass(SettingsNormalCell.self, forCellReuseIdentifier: String(SettingsNormalCell))
    }
    
    func updateData(with settings: [Setting]) {
        self.settings = settings
        tableView?.reloadData()
    }
    
    func updateData(with gender: Gender) {
        guard let index = settings.indexOf({ $0.type == CellType.Gender }) else {
            return
        }
        if settings[index].value as? Gender == gender {
            return
        }
        settings[index].value = gender
        tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let setting = settings[indexPath.row]
        
        switch setting.type {
        case .Header:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(SettingsHeaderCell), forIndexPath: indexPath) as! SettingsHeaderCell
            cell.facebookAction = setting.action
            cell.instagramAction = setting.secondaryAction
            return cell
            
        case .Login:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(SettingsLoginCell), forIndexPath: indexPath) as! SettingsLoginCell
            cell.loginAction = setting.action
            cell.createAccountAction = setting.secondaryAction
            return cell
            
        case .Logout:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(SettingsLogoutCell), forIndexPath: indexPath) as! SettingsLogoutCell
            cell.labelText = setting.labelString
            cell.logoutAction = setting.action
            return cell
            
        case .Gender:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(SettingsGenderCell), forIndexPath: indexPath) as! SettingsGenderCell
            cell.selectedGender = setting.value as? Gender
            cell.femaleAction = setting.action
            cell.maleAction = setting.secondaryAction
            return cell
            
        case .Normal:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(SettingsNormalCell), forIndexPath: indexPath) as! SettingsNormalCell
            cell.labelText = setting.labelString
            return cell

        }
    }
}