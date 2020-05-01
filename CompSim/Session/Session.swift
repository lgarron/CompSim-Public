//
//  Session.swift
//  CompSim
//
//  Created by Rami Sbahi on 12/10/19.
//  Copyright © 2019 Rami Sbahi. All rights reserved.
//

import Foundation
import RealmSwift

class Session: Object
{
    @objc dynamic var currentIndex = 0 // new
    
    @objc dynamic var name: String = ""
    @objc dynamic var minTime = 500 // distribution
    @objc dynamic var maxTime = 900 // distribution
    @objc dynamic var singleTime = 750 // single time
    @objc dynamic var targetType = 1 // 0 = none, 1 = single, 2 = range
    
    @objc dynamic var minIndex = 0 // new
    @objc dynamic var maxIndex = 1 // new
    
    @objc dynamic var solveType: Int = 0 // 0 = ao5, 1 = mo3, 2 = bo3
    
    let times = List<SolveTime>() // current times // new
    
    var myAverage: String = ""
    var myAverageInt: Int = 0
    var intTotal: Int = 0
    
    // following all persist:
    var allAverages = List<String>()
    var averageTypes = List<Int>()
    var winningAverages = List<String>()
    var usingWinningTime = List<Bool>()
    var results = List<Bool>()
    var allTimes = List<SolveTimeList>()
    
    @objc dynamic var currentAverage: Int = -1 // keeps track of last average currently on (round - 2)
    @objc dynamic var event: Int = 1
    
    var scrambler: ScrambleReader = ScrambleReader(event: 1)
    
    convenience init(name: String, enteredEvent: Int) {
        self.init()
        self.name = name
        scrambler = ScrambleReader(event: enteredEvent)
        updateScrambler()
        
    }
    
    func updateScrambler()
    {
        scrambler.doEvent(event: event)
    }
    
    func doEvent(enteredEvent: Int)
    {
        event = enteredEvent
        updateScrambler()
    }
    
    func reset()
    {
        currentIndex = 0
        times.removeAll()
        minIndex = 0
        maxIndex = 1
        myAverage = ""
    }
    
    func deleteSolve()
    {
        times.removeLast()
        currentIndex -= 1
        updateTimes()
    }
    
    func getCurrentScramble() -> String
    {
        return scrambler.currentScramble
    }
    
    func addSolve(time: String)
    {
        let myTime = SolveTime(enteredTime: time, scramble: scrambler.currentScramble)
        times.append(myTime)
        currentIndex += 1
        updateTimes()
        scrambler.genScramble()
        
    }
    
    func addSolve(time: String, penalty: Int)
    {
        let myTime = SolveTime(enteredTime: time, scramble: scrambler.currentScramble)
        if(penalty == 1)
        {
            myTime.setPlusTwo()
        }
        else if(penalty == 2)
        {
            myTime.setDNF()
        }
        times.append(myTime)
        currentIndex += 1
        updateTimes()
        scrambler.genScramble()
        
    }
    
    func changePenaltyStatus(index: Int, penalty: Int)
    {
        if(penalty == 0)
        {
            times[index].setNoPenalty()
        }
        else if(penalty == 1)
        {
            times[index].setPlusTwo()
        }
        else
        {
            times[index].setDNF()
        }
        updateTimes()
    }
    
    func updateTimes()
    {
        intTotal = 0
        if(currentIndex >= 3 && HomeViewController.mySession.solveType == 0)
        {
            minIndex = 0
            maxIndex = 1
            for i in 0..<currentIndex
            {
                if(times[i].intTime < times[minIndex].intTime)
                {
                    minIndex = i
                }
                else if(times[i].intTime > times[maxIndex].intTime)
                {
                    maxIndex = i
                }
            }
            
            for i in 0..<currentIndex
            {
                if(i == minIndex || i == maxIndex)
                {
                    times[i].updateString(minMax: true)
                }
                else
                {
                    times[i].updateString(minMax: false)
                    intTotal += times[i].intTime // for calculating average (might do)
                }
            }
        }
        else if HomeViewController.mySession.solveType == 1
        {
            for i in 0..<currentIndex
            {
                times[i].updateString(minMax: false)
                intTotal += times[i].intTime
            }
        }
        else if HomeViewController.mySession.solveType == 2
        {
            minIndex = 0
            for i in 0..<currentIndex
            {
                times[i].updateString(minMax: false)
                if(times[i].intTime < times[minIndex].intTime)
                {
                    minIndex = i
                }
            }
            intTotal = times[minIndex].intTime
        }
        else // avg5, but not min/max yet
        {
            for i in 0..<currentIndex
            {
                times[i].updateString(minMax: false)
            }
        }
    }
    
    func finishAverage() // give int total
    {
        if(currentIndex == 5 && HomeViewController.mySession.solveType == 0) // done with avg5
        {
            averageTypes.append(0)
        }
        else if(currentIndex == 3 && HomeViewController.mySession.solveType > 0) // done with mo3 / bo3
        {
            times.append(SolveTime(enteredTime: "0", scramble: ""))
            times.append(SolveTime(enteredTime: "0", scramble: ""))
            HomeViewController.mySession.solveType == 1 ? averageTypes.append(1) : averageTypes.append(2)
        }
        let timesArray = Array(times)
        allTimes.append(SolveTimeList(timesArray))
        if(intTotal > 950000) // has counting DNF
        {
            myAverage = "DNF"
            myAverageInt = 999999
        }
        else
        {
            var averageTime = 0
            if HomeViewController.mySession.solveType == 2
            {
                averageTime = intTotal
            }
            else
            {
                averageTime = (intTotal + 1) / 3 // mo3 of ao5
            }
            myAverageInt = averageTime
            myAverage = SolveTime.makeMyString(num: averageTime)
        }
        allAverages.append(myAverage)
        currentAverage += 1
    }
    
    
    
}
