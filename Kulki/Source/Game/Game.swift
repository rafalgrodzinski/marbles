//
//  Game.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


public class Game: NSObject
{
    internal(set) var view: UIView!
    internal var field: Field
    internal var currentState: State?
    private var states: [State]!

    // State data
    private var isWaitingForMove = false
    private var selectedMarble: Marble?
    private var drawnMarbleColors: [Int]?
    private var spawnedMarbles: [Marble]?

    // Callbacks
    public var pauseCallback: (() -> Void)?
    public var quitCallback: (() -> Void)?

    // MARK: - Initialization -
    init(field: Field)
    {
        self.field = field
        super.init()
        
        self.setupView()
        assert(self.view != nil, "self.view must not be nil")

        // Setup states
        let startupState = State()
        startupState.command = { [weak self] (state: State) in self?.executeStartupState(state) }

        let spawnState = State()
        spawnState.command = { [weak self] (state: State) in self?.executeSpawnState(state) }

        let removeAfterSpawnState = State()
        removeAfterSpawnState.command = { [weak self] (state: State) in self?.executeRemoveAfterSpawnState(state) }

        let checkIfFinishedState = State()
        checkIfFinishedState.command = { [weak self] (state: State) in self?.executeCheckIfFinishedState(state) }

        let moveState = State()
        moveState.command = { [weak self] (state: State) in self?.executeMoveState(state) }

        let removeAfterMoveState = State()
        removeAfterMoveState.command = { [weak self] (state: State) in self?.executeRemoveAfterMoveState(state) }

        let finishedState = State()
        finishedState.command = { [weak self] (state: State) in self?.executeFinishedState(state) }

        // Startup -> Spawn
        startupState.nextState = spawnState
        // Spawn -> Remove after spawn
        spawnState.nextState = removeAfterSpawnState
        // Remove after spawn -> Check if finished
        removeAfterSpawnState.nextState = checkIfFinishedState
        // Check if finished -> Wait for move (or finished)
        checkIfFinishedState.nextState = moveState
        // Moving -> Remove after move
        moveState.nextState = removeAfterMoveState
        // Remove after move  -> Spawn
        removeAfterMoveState.nextState = spawnState

        self.states = [startupState, spawnState, removeAfterSpawnState, checkIfFinishedState,
                       moveState, removeAfterMoveState, finishedState]
    }


    // MARK: <<Abstract>>
    internal func setupView()
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: <<Abstract>>
    internal func setupCustom()
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: - Control -
    public func startGame()
    {
        // Setup score singleton
        ScoreSingleton.sharedInstance.newGameWithColorsCount(self.field.colorsCount, lineLength: self.field.lineLength)
        // Reset the field (in case the game was restarted)
        self.field.reset()

        // Load all the objects
        self.setupCustom()

        self.states[0].execute()
    }


    // MARK: - State -
    func executeStartupState(state: State)
    {
        self.currentState = state

        self.drawnMarbleColors = self.field.drawNextMarbleColors()
        self.showBoard(state.goToNextState)
    }


    func executeSpawnState(state: State)
    {
        self.currentState = state

        self.spawnedMarbles = self.field.spawnMarbles(self.drawnMarbleColors!)
        self.drawnMarbleColors = self.field.drawNextMarbleColors()
        self.showMarbles(spawnedMarbles!, nextMarbleColors: self.drawnMarbleColors!, finished: state.goToNextState)
    }


    func executeRemoveAfterSpawnState(state: State)
    {
        self.currentState = state

        var removedMarbles = [Marble]()

        for marble in self.spawnedMarbles! {
            let lineOfMarbles = self.field.removeLinesAtMarble(marble)
            removedMarbles.appendContentsOf(lineOfMarbles)

            ScoreSingleton.sharedInstance.removedMarbles(lineOfMarbles.count)
        }

        if removedMarbles.count > 0 {
            self.hideMarbles(removedMarbles, finished: state.goToNextState)
            self.updateScore(ScoreSingleton.sharedInstance.currentScore)
        } else {
            state.goToNextState()
        }
    }


    func executeCheckIfFinishedState(state: State)
    {
        self.currentState = state

        if self.field.isFull {
            let finishedState = self.states.last!
            finishedState.execute()
        } else {
            state.goToNextState()
        }
    }


    func executeMoveState(state: State)
    {
        self.currentState = state
        self.selectedMarble = nil
        self.isWaitingForMove = true
    }


    func executeRemoveAfterMoveState(state: State)
    {
        let removedMarbles = self.field.removeLinesAtMarble(self.selectedMarble!)
        self.selectedMarble = nil

        ScoreSingleton.sharedInstance.removedMarbles(removedMarbles.count)

        if removedMarbles.count > 0 {
            // get move state
            let currentStateIndex = self.states.indexOf(state)
            let moveState = self.states[currentStateIndex!.advancedBy(-1)]

            self.hideMarbles(removedMarbles, finished: moveState.execute)
            self.updateScore(ScoreSingleton.sharedInstance.currentScore)
        } else {
            state.goToNextState()
        }
    }


    func executeFinishedState(state: State)
    {
        self.currentState = state

        let score = ScoreSingleton.sharedInstance.currentScore
        let isHighScore = ScoreSingleton.sharedInstance.currentScore > ScoreSingleton.sharedInstance.highScore
        if isHighScore {
            ScoreSingleton.sharedInstance.highScore = score
        }

        self.gameFinished(score, isHighScore: isHighScore)
    }


    // MARK: - Startup -

    // MARK: <<Abstract>>
    func showBoard(finished: () -> Void)
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: - Spawn -

    // MARK: <<Abstract>>
    func showMarbles(marbles: [Marble], nextMarbleColors: [Int], finished: () -> Void)
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: - Remove -

    // MARK: <<Abstract>>
    func hideMarbles(marbles: [Marble], finished: () -> Void)
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: <<Abstract>>
    func updateScore(newScore: Int)
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: - Move -
    func tappedFieldPosition(fieldPosition: Point)
    {
        if !self.isWaitingForMove {
            return
        }

        // Are we trying to select a marble?
        if let marble = self.field.marbles[fieldPosition] {
            // Ignore if already selected
            if marble === self.selectedMarble {
                return
            }

            // Deselect currently selected marble
            if let selectedMarble = self.selectedMarble {
                self.deselectMarble(selectedMarble)
            }

            self.selectedMarble = marble
            self.selectMarble(marble)
        // Otherwise, might be trying to move a marble
        } else if let selectedMarble = self.selectedMarble {
            if let path = self.field.moveMarble(selectedMarble, toPosition: fieldPosition) {
                self.isWaitingForMove = false
                self.deselectMarble(selectedMarble)
                self.moveMarble(selectedMarble, overFieldPath: path, finished: self.currentState!.goToNextState)
            }
        }
    }


    // MARK: <<Abstract>>
    func selectMarble(marbe: Marble)
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: <<Abstract>>
    func deselectMarble(marbe: Marble)
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: <<Abstract>>
    func moveMarble(marble: Marble, overFieldPath fieldPath: [Point], finished: () -> Void)
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: - Finished -

    // MARK: <<Abstract>>
    func gameFinished(score: Int, isHighScore: Bool)
    {
        assert(false, "<<Abstract method>>")
    }
}
