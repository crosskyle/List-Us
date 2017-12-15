import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var messageBodyView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
