//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Andrew Llewellyn on 7/16/18.
//  Copyright © 2018 Andrew Llewellyn. All rights reserved.
//

import Foundation
import UIKit
import CoreData


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
