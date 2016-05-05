//
//  Game.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class Game: NSObject
{
    internal(set) var view: UIView!
    internal var field: Field
    internal var currentState: State?
    private var states: [State]!

    // State data
    private var isWaitingForMove = false
    private var selectedMarble: Marble?
    private var spawnedMarbles: [Marble]?


    // MARK: - Initialization -
    init(field: Field)
    {

        self.field = field
        super.init()
        self.setupView()
        assert(self.view != nil, "self.view must not be nil")

        // Setup score singleton
        ScoreSingleton.sharedInstance.newGameWithColorsCount(self.field.colorsCount, lineLength: self.field.lineLength)

        // Setup states
        let startupState = State()
        startupState.command = self.executeStartupState

        let spawnState = State()
        spawnState.command = self.executeSpawnState

        let removeAfterSpawnState = State()
        removeAfterSpawnState.command = self.executeRemoveAfterSpawnState

        let checkIfFinishedState = State()
        checkIfFinishedState.command = self.executeCheckIfFinishedState

        let moveState = State()
        moveState.command = self.executeMoveState

        let removeAfterMoveState = State()
        removeAfterMoveState.command = self.executeRemoveAfterMoveState

        let finishedState = State()
        finishedState.command = self.executeFinishedState

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
    func setupView()
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: <<Abstract>>
    func setupCustom()
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: - Control -
    func startGame()
    {
        self.setupCustom()

        self.states[0].execute()
    }


    // MARK: - State -
    func executeStartupState(state: State)
    {
        self.currentState = state

        self.showBoard(state.goToNextState)
    }


    func executeSpawnState(state: State)
    {
        self.currentState = state

        self.spawnedMarbles = self.field.spawnMarbles()
        self.showMarbles(spawnedMarbles!, finished: state.goToNextState)
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
            print("Game is finished")
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
            self.hideMarbles(removedMarbles, finished: state.goToNextState)
            self.updateScore(ScoreSingleton.sharedInstance.currentScore)
        } else {
            state.goToNextState()
        }
    }


    func executeFinishedState(state: State)
    {
        self.currentState = state
    }


    // MARK: - Startup -

    // MARK: <<Abstract>>
    func showBoard(finished: () -> Void)
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: - Spawn -

    // MARK: <<Abstract>>
    func showMarbles(marbles: [Marble], finished: () -> Void)
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
}
