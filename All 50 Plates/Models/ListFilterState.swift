//
//  ListFilterState.swift
//  All 50 Plates
//
//  Created by Eric Ziegler on 7/29/23.
//

import Foundation

enum ListFilterState: Int {
    case allPlates
    case found
    case notFound
    
    var displayText: String {
        switch self {
        case .allPlates:
            return "All Plates"
        case .found:
            return "Found"
        case .notFound:
            return "Not Found"
        }
    }
}

extension ListFilterState {
    var emptyImage: String {
        switch self {
        case .allPlates:
            return "exclamationmark.triangle"
        case .found:
            return "magnifyingglass"
        case .notFound:
            return "checkmark"
        }
    }
    
    var emptyTitle: String {
        switch self {
        case .allPlates:
            return "Uh oh!"
        case .found:
            return "No Plates Found!"
        case .notFound:
            return "Congratulations"
        }
    }
    
    var emptyMessage: String {
        switch self {
        case .allPlates:
            return "Something went terribly wrong!"
        case .found:
            return "You haven't found any plates yet."
        case .notFound:
            return "You found all the plates!"
        }
    }
}
