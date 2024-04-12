//
//  Date+Extension.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 21/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import Foundation

extension Date {
    
    func timeAgoSinceDate(numericDates: Bool) -> String {
        
        let date = self
        let now = Date()
        let earliest = (date < now) ? date : now
        let latest = (earliest == now) ? date : now
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year, .second], from: earliest, to: latest)
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        } else if let year = components.year, year >= 1 {
            return (numericDates) ? "1 year ago" : "Last year"
        } else if let month = components.month, month >= 2 {
            return "\(month) months ago"
        } else if let month = components.month, month >= 1 {
            return (numericDates) ? "1 month ago" : "Last month"
        } else if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        } else if let week = components.weekOfYear, week >= 1 {
            return (numericDates) ? "1 week ago" : "Last week"
        } else if let day = components.day, day >= 2 {
            return "\(day) days ago"
        } else if let day = components.day, day >= 1 {
            return (numericDates) ? "1 day ago" : "Yesterday"
        } else if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        } else if let hour = components.hour, hour >= 1 {
            return (numericDates) ? "1 hour ago" : "An hour ago"
        } else if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        } else if let minute = components.minute, minute >= 1 {
            return (numericDates) ? "1 minute ago" : "A minute ago"
        } else if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        } else {
            return "Just now"
        }
    }
}
