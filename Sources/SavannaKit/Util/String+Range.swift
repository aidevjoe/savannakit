//
//  String+Range.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

extension String {
	
	func nsRange(fromRange range: Range<Index>) -> NSRange {
		return Foundation.NSRange(range, in: self)
	}

    func NSRange(of substring: String) -> NSRange? {
        // Get the swift range
        guard let range = range(of: substring) else { return nil }

        // Get the distance to the start of the substring
        let start = distance(from: startIndex, to: range.lowerBound) as Int
        //Get the distance to the end of the substring
        let end = distance(from: startIndex, to: range.upperBound) as Int

        //length = endOfSubstring - startOfSubstring
        //start = startOfSubstring
        return NSMakeRange(start, end - start)
    }

}
