//
//  UIView+ES_Extension.swift
//  百度下拉刷新
//
//  Created by EnjoySR on 15/11/22.
//  Copyright © 2015年 EnjoySR. All rights reserved.
//

import UIKit

extension UIView {
    var es_x: CGFloat {
        
        get{
            return self.frame.origin.x
        }
        
        set{
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    
    var es_y: CGFloat {
        
        get{
            return self.frame.origin.y
        }
        
        set{
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var es_width: CGFloat {
        
        get{
            return self.frame.size.width
        }
        
        set{
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var es_height: CGFloat {
        
        get{
            return self.frame.size.height
        }
        
        set{
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var es_size: CGSize {
        
        get{
            return self.frame.size
        }
        
        set{
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    var es_centerX: CGFloat {
        
        get{
            return self.center.x
        }
        
        set{
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }
    
    var es_centerY: CGFloat {
        
        get{
            return self.center.y
        }
        
        set{
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }
}

