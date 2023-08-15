//
//  UDStringExtansion.swift
//  UseDesk_SDK_Swift
//
import UIKit

extension String {
    public var udIsContainEmoji: Bool {
        for ucode in unicodeScalars {
            switch ucode.value {
            case 0x3030, 0x00AE, 0x00A9,
            0x1D000...0x1F77F,
            0x2100...0x27BF,
            0xFE00...0xFE0F,
            0x1F900...0x1F9FF:
                return true
            default:
                continue
            }
        }
        return false
    }

    func size(availableWidth: CGFloat? = nil, attributes: [NSAttributedString.Key : Any]? = nil, usesFontLeading: Bool = true) -> CGSize {
        var attributes = attributes
        let systemFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let font: UIFont = (attributes?[.font] as? UIFont) ?? systemFont
        
        if attributes == nil {
            attributes = [.font : font]
        }
        
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        let singleSymbolHeight = self.singleLineHeight(attributes: attributes!)
        let availableSize = CGSize(width: availableWidth ?? .greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        
        var sizeWithAttributedString: CGSize
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin]
        let drawingRect = attributedString.boundingRect(with: availableSize, options: options, context: nil)
        sizeWithAttributedString = drawingRect.size
        
        if !usesFontLeading {
            return sizeWithAttributedString
        }
        
        // Leading causes incorrect calculation for text layer
        if usesFontLeading {
            let linesCount = ceil(sizeWithAttributedString.height / singleSymbolHeight)
            let totalHeight = ceil(sizeWithAttributedString.height + abs(font.leading) * linesCount)
            sizeWithAttributedString.height = totalHeight
        }
        
        let size = CGSize(width: sizeWithAttributedString.width.rounded(.up),
                          height: sizeWithAttributedString.height.rounded(.up))
        
        return size
    }
    
    func udIsValidEmail() -> Bool {
        let udEmailRegex = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z_])?" + "@" + "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}" + "[A-Za-z]{2,8}"
        let range = NSRange(location: 0, length: self.count)
        let regex = try! NSRegularExpression(pattern: udEmailRegex)
        return regex.firstMatch(in: self, options: [], range: range) != nil && !self.udIsHtml()
    }
    
    func udIsValidToken() -> Bool {
        if self.udIsContainEmoji || self.contains(" ") || self.count < 64 {
            return false
        }
        return true
    }
    
    func udIsValidUrl() -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if URL(string: self) != nil,
           let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    func udIsHtml() -> Bool {
        let htmlTags: [String] = ["<!--","<!DOCTYPE","<a","<abbr","<acronym","<address","<applet","<area","<article","<aside","<audio","<b","<base","<basefont","<bdi","<bdo","<big","<blockquote","<body","<br","<button","<canvas","<caption","<center","<cite","<code","<col","<colgroup","<data","<datalist","<dd","<del","<details","<dfn","<dialog","<dir","<div","<dl","<dt","<em","<embed","<fieldset","<figcaption","<figure","<font","<footer","<form","<frame","<frameset","<h1","<h2","<h3","<h4","<h5","<h6","<head","<header","<hr","<html","<i","<iframe","<img","<input","<ins","<kbd","<label","<legend","<li","<link","<main","<map","<mark","<menu","<menuitem","<meta","<meter","<nav","<noframes","<noscript","<object","<ol","<optgroup","<option","<output","<param","<picture","<pre","<progress","<q","<rp","<rt","<ruby","<s","<samp","<script","<section","<select","<small","<source","<span","<strike","<strong","<style","<sub","<summary","<sup","<svg","<table","<tbody","<td","<template","<textarea","<tfoot","<th","<thead","<time","<title","<tr","<track","<tt","<u","<ul","<var","<video","<wbr","<p","</p"]
        var isHtml = false
        var index = 0
        while index < htmlTags.count && !isHtml {
            if self.contains(htmlTags[index]) {
                isHtml = true
            } else {
                index += 1
            }
        }
        return isHtml
    }
    
    func udGetLinksRange() -> [Range<String.Index>] {
        var links: [Range<String.Index>] = []
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))

        for match in matches {
            if let range = Range(match.range, in: self) {
                links.append(range)
            }
        }
        return links
    }
    
    func udRemoveSubstrings(with substrings: [String]) -> String {
        var resultString = self
        substrings.forEach { string in
            resultString = resultString.replacingOccurrences(of: string, with: "", options: String.CompareOptions.regularExpression, range: nil)
        }
        return resultString
    }
    
    func udRemoveMultipleLineBreaks() -> String {
        guard self.contains("\n") else {return self}
        var resultString = ""
        var index = 0
        while index < self.count - 1 {
            if let searchStartIndex = self.index(startIndex, offsetBy: index, limitedBy: self.endIndex) {
                if self[searchStartIndex] == "\n" {
                    var endIndexMultipleLineBreaks = index + 1
                    var isFindEndMultipleLineBreaks = false
                    var countMultipleLineBreaks = 0
                    var isEndSpace = false
                    while endIndexMultipleLineBreaks < self.count - 1 && !isFindEndMultipleLineBreaks {
                        if let searchEndIndexMultipleLineBreaks = self.index(startIndex, offsetBy: endIndexMultipleLineBreaks, limitedBy: self.endIndex),
                           self[searchEndIndexMultipleLineBreaks] == "\n" {
                            countMultipleLineBreaks += 1
                            index += 1
                            isEndSpace = false
                        } else if let searchEndIndexMultipleLineBreaks = self.index(startIndex, offsetBy: endIndexMultipleLineBreaks, limitedBy: self.endIndex),
                                  self[searchEndIndexMultipleLineBreaks] == " " {
                            isEndSpace = true
                            index += 1
                        } else {
                            isFindEndMultipleLineBreaks = true
                        }
                        endIndexMultipleLineBreaks += 1
                    }
                    if countMultipleLineBreaks > 0 {
                        resultString.append("\n\n")
                    } else {
                        resultString.append("\n")
                    }
                    if isEndSpace {
                        index -= 1
                    }
                } else {
                    resultString.append(self[searchStartIndex] )
                }
                index += 1
            }
        }
        if self.last != "\n" {
            resultString.append(self.last ?? Character(""))
        }
        return resultString
    }
    
    func udRemoveFirstSpaces() -> String {
        return self.udRemoveFirstSymbol(with: " ")
    }
    
    func udRemoveFirstSymbol(with symbol: Character) -> String {
        var resultString = self
        var isNeedRemove = resultString.first == symbol ? true : false
        let maxCountRepeat = 100000
        var countRepeat = 0
        while isNeedRemove && countRepeat < maxCountRepeat {
            resultString.removeFirst()
            isNeedRemove = resultString.first == symbol ? true : false
            countRepeat += 1
        }
        return resultString
    }
    
    func udRemoveLastSymbol(with symbol: Character) -> String {
        var resultString = self
        var isNeedRemove = resultString.last == symbol ? true : false
        let maxCountRepeat = 100000
        var countRepeat = 0
        while isNeedRemove && countRepeat < maxCountRepeat {
            resultString.removeLast()
            isNeedRemove = resultString.last == symbol ? true : false
            countRepeat += 1
        }
        return resultString
    }
    
    func udRemoveFirstAndLastLineBreaksAndSpaces() -> String {
        var resultString = self
        let maxCountRepeat = 10000
        var countRepeat = 0
        while (resultString.first == " " || resultString.first == "\n" || resultString.last == " " || resultString.last == "\n") && countRepeat < maxCountRepeat {
            resultString = resultString.udRemoveFirstSymbol(with: "\n")
            resultString = resultString.udRemoveFirstSymbol(with: " ")
            resultString = resultString.udRemoveLastSymbol(with: "\n")
            resultString = resultString.udRemoveLastSymbol(with: " ")
            countRepeat += 1
        }
        return resultString
    }
    
    mutating func udRemoveMarkdownUrlsAndReturnLinks() -> [String] {
        guard self.count > 5 else {return []}
        var links: [String] = []
        let maxCountRepeat = 1000
        var countRepeat = 0
        var flag = true
        var startRangeIndex = self.startIndex
        while countRepeat < maxCountRepeat && flag {
            guard udIsIndexValid(startRangeIndex) else {break}
            guard let endRangeIndex = self.index(self.endIndex, offsetBy: -1, limitedBy: self.startIndex) else {break}
            if let range = self[startRangeIndex...endRangeIndex].range(of: "![") {
                let startIndex = range.lowerBound
                if let index = self.index(startIndex, offsetBy: 1, limitedBy: self.endIndex), udIsIndexValid(index) {
                    startRangeIndex = index
                }
                var isFindEnd = false
                var index = 0
                while !isFindEnd {
                    if let searchStartIndex = self.index(startIndex, offsetBy: index, limitedBy: self.endIndex),
                       let searchEndIndex = self.index(searchStartIndex, offsetBy: 1, limitedBy: self.endIndex),
                       udIsIndexValid(searchStartIndex),
                       udIsIndexValid(searchEndIndex) {
                        if self[searchStartIndex...searchEndIndex] == "](" {
                            var indexSearchEndLink = 0
                            while !isFindEnd {
                                if let searchIndex = self.index(searchEndIndex, offsetBy: indexSearchEndLink, limitedBy: self.endIndex),
                                   udIsIndexValid(searchIndex) {
                                    if self[searchIndex] == ")" {
                                        // get link
                                        var linkPath = ""
                                        if let startLinkIndex = self.index(searchEndIndex, offsetBy: +1, limitedBy: self.endIndex),
                                           let endLinkIndex = self.index(searchIndex, offsetBy: -1, limitedBy: self.startIndex),
                                           endLinkIndex > startLinkIndex,
                                           udIsIndexValid(startLinkIndex),
                                           udIsIndexValid(endLinkIndex) {
                                            linkPath = String(self[startLinkIndex...endLinkIndex])
                                            
                                        }
                                        isFindEnd = true
                                        if linkPath.udIsValidUrl() {
                                            // add link
                                            links.append(linkPath)
                                            //remove link
                                            if udIsIndexValid(startIndex) && udIsIndexValid(searchIndex) {
                                                self = self.replacingOccurrences(of: self[startIndex...searchIndex], with: "")
                                            }
                                            if self.startIndex > startIndex {
                                                if let enterIndex = self.index(startIndex, offsetBy: -1, limitedBy: self.startIndex) {
                                                    if self[enterIndex] == "\n" {
                                                        self.remove(at: enterIndex)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    isFindEnd = true
                                }
                                indexSearchEndLink += 1
                            }
                        }
                    } else {
                        isFindEnd = true
                    }
                    index += 1
                }
            } else {
                flag = false
            }
            countRepeat += 1
        }
        return links
    }
    
    func udIsIndexValid(_ index: Index) -> Bool {
        return self.endIndex > index && self.startIndex <= index
    }
    
    mutating func udConvertUrls() {
        var count = 0
        var flag = true
        var string = self
        while count < 9000 && flag {
            if let range = string.range(of: "<http") {
                var startIndex = range.lowerBound
                var isFindEnd = false
                var index = 0
                while !isFindEnd {
                    if let searchEndIndex = string.index(startIndex, offsetBy: index, limitedBy: string.endIndex),
                       udIsIndexValid(searchEndIndex) {
                        if string[searchEndIndex] == ">" {
                            isFindEnd = true
                            string = string.replacingOccurrences(of: self[searchEndIndex...searchEndIndex], with: "")
                            string = string.replacingOccurrences(of: self[startIndex...startIndex], with: "")
                        }
                    } else {
                        isFindEnd = true
                    }
                    index += 1
                }
            } else {
                flag = false
            }
            count += 1
        }
        self = string
    }
    
    mutating func udConverDoubleLinks() {
        guard self.count > 19, self.contains("[](") else {return}
        let patternAllConstructionUrl = "(\\[\\]\\([a-zA-Zа-яА-Я0-9:@.-_]{1,250}\\)[a-zA-Zа-яА-Я0-9<>-_\n@.]{1,250}\\[\\]\\([a-zA-Zа-яА-Я0-9:@.-_]{1,250}\\))"
        let patternUrl = "(\\)[a-zA-Zа-яА-Я0-9<>\n@.]{1,250}\\[)"
        var range = NSRange(location: 0, length: self.count)
        let regexAllConstructionUrl = try! NSRegularExpression(pattern: patternAllConstructionUrl)
        let regexUrl = try! NSRegularExpression(pattern: patternUrl)
        var isExistConstructionUrl = regexAllConstructionUrl.firstMatch(in: self, options: [], range: range) != nil
        var countRepeat = 0
        let maxCountRepeat = 1000
        while countRepeat < maxCountRepeat && isExistConstructionUrl {
            let rangeAllConstructionUrlInSelf = regexAllConstructionUrl.rangeOfFirstMatch(in: self, range: range)
            let allConstructionUrl = self[rangeAllConstructionUrlInSelf.location - 1..<rangeAllConstructionUrlInSelf.lowerBound + rangeAllConstructionUrlInSelf.length]
            let rangeAllConstructionUrl = NSRange(location: 0, length: allConstructionUrl.count)
            if regexUrl.firstMatch(in: allConstructionUrl, options: [], range: rangeAllConstructionUrl) != nil {
                let rangeUrl = regexUrl.rangeOfFirstMatch(in: allConstructionUrl, range: rangeAllConstructionUrl)
                let url = allConstructionUrl[rangeUrl.lowerBound + 1..<(rangeUrl.lowerBound + rangeUrl.length - 1)]
                self = self.replacingOccurrences(of: allConstructionUrl, with: url)
            }
            range = NSRange(location: 0, length: self.count + 1)
            isExistConstructionUrl = regexAllConstructionUrl.firstMatch(in: self, options: [], range: range) != nil
            countRepeat += 1
        }
    }

    private func singleLineHeight(attributes: [NSAttributedString.Key : Any]) -> CGFloat {
        let attributedString = NSAttributedString(string: "0", attributes: attributes)
        
        return attributedString.size().height
    }
    
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound, range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

extension RangeExpression where Bound == String.Index  {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}
