// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import UIKit

protocol MyTableViewCellDelegate: AnyObject{
    func didTapButton(with title:String)
}
class MyTableViewCell: UITableViewCell {

    weak var delegate: MyTableViewCellDelegate?
    
    static let identifier = "MyTableViewCell"
    
    static func nib()->UINib{
        return UINib(nibName: "MyTableViewCell", bundle: nil)
    }
    @IBOutlet var button: UIButton!
    private var title: String = ""
    
    @IBAction func didTapButton()
    {
        delegate?.didTapButton(with: title)
        if title.starts(with: "Subscribe")
        {
            button.isEnabled = false
            button.setTitle("Subscribed", for: .disabled)
        }
    }
    
    func configure(with title: String)
    {
        self.title = title
        button.setTitle(title, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        button.setTitleColor(.link, for: .normal)
    }

    
}
