//
//  RegexLexer.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 05/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public typealias TokenTransformer = (_ range: NSRange) -> Token

public struct RegexTokenGenerator {
	
	public let regularExpression: NSRegularExpression
	
	public let tokenTransformer: TokenTransformer
	
	public init(regularExpression: NSRegularExpression, tokenTransformer: @escaping TokenTransformer) {
		self.regularExpression = regularExpression
		self.tokenTransformer = tokenTransformer
	}
}

public struct KeywordTokenGenerator {
	
	public let keywords: [String]
	
	public let tokenTransformer: TokenTransformer
	
	public init(keywords: [String], tokenTransformer: @escaping TokenTransformer) {
		self.keywords = keywords
		self.tokenTransformer = tokenTransformer
	}
	
}

public enum TokenGenerator {
	case keywords(KeywordTokenGenerator)
	case regex(RegexTokenGenerator)
}

public protocol RegexLexer: Lexer {
	
	func generators(source: String) -> [TokenGenerator]
	
}

extension RegexLexer {
	
	public func getSavannaTokens(input: String) -> [Token] {
		
		let generators = self.generators(source: input)
		
		var tokens = [Token]()
		
		for generator in generators {
			
			switch generator {
			case .regex(let regexGenerator):
				tokens.append(contentsOf: generateRegexTokens(regexGenerator, source: input))

			case .keywords(let keywordGenerator):
				tokens.append(contentsOf: generateKeywordTokens(keywordGenerator, source: input))
				
			}
		
		}
	
		return tokens
	}

}

extension RegexLexer {

	func generateKeywordTokens(_ generator: KeywordTokenGenerator, source: String) -> [Token] {

		var tokens = [Token]()

		source.enumerateSubstrings(in: source.startIndex..<source.endIndex, options: [.byWords]) { (word, range, _, _) in

			if let word = word, generator.keywords.contains(word), let range = source.NSRange(of: word) {

               let token = generator.tokenTransformer(range)
				tokens.append(token)

			}

		}

		return tokens
	}
	
	public func generateRegexTokens(_ generator: RegexTokenGenerator, source: String) -> [Token] {

		var tokens = [Token]()

		let fullNSRange = NSRange(location: 0, length: source.utf16.count)
		for numberMatch in generator.regularExpression.matches(in: source, options: [], range: fullNSRange) {
            
            var outRange = numberMatch.range
            
            if outRange.length == 0, numberMatch.numberOfRanges > 1 {
                
                outRange = numberMatch.range(at: 1)
            }
            
            let token = generator.tokenTransformer(outRange)
			tokens.append(token)
			
		}
		
		return tokens
	}
    
    public var keywords: [String] {
        
        var list = [String]()
        
        for generator in generators(source: "") {
            switch generator {
            case .keywords(let generator):
                list.append(contentsOf: generator.keywords)
            default:
                break
            }
        }
        
        return list
    }

}

extension String {

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
