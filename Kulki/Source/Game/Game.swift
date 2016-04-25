//
//  Game.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class Game {
    internal(set) var view: UIView!
    internal var field: Field
    internal var currentState: State?
    private var states: [State]!
    private var isWaitingForMove = false
    private var selectedMarble: Marble?


    // MARK: - Initialization -
    init(field: Field)
    {
        self.field = field
        self.setupView()
        assert(self.view != nil, "self.view must not be nil")

        // Setup states
        let startupState = State()
        startupState.command = self.executeStartupState

        let spawnState = State()
        spawnState.command = self.executeSpawnState

        let removeAfterSpawnState = State()
        removeAfterSpawnState.command = self.executeRemoveAfterSpawnState

        let checkIfFinishedState = State()
        checkIfFinishedState.command = self.executeCheckIfFinishedState

        let waitForMoveState = State()
        waitForMoveState.command = self.executeWaitForMoveState

        let movingState = State()
        movingState.command = self.executeMovingState

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
        checkIfFinishedState.nextState = waitForMoveState
        // Wait for move -> Moving
        waitForMoveState.nextState = movingState
        // Moving -> Remove after move
        movingState.nextState = removeAfterMoveState
        // Remove after move  -> Spawn
        removeAfterMoveState.nextState = spawnState

        self.states = [startupState, spawnState, removeAfterSpawnState, checkIfFinishedState,
                       waitForMoveState, movingState, removeAfterMoveState, finishedState]
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
    func executeStartupState(state: State, finished: (() -> Void)?)
    {
        self.currentState = state

        self.showBoard(finished!)
    }


    func executeSpawnState(state: State, finished: (() -> Void)?)
    {
        self.currentState = state

        let spawnedMarbles = self.field.spawnMarbles()
        self.showMarbles(spawnedMarbles, finished: finished!)
    }


    func executeRemoveAfterSpawnState(state: State, finished: (() -> Void)?)
    {
        self.currentState = state

        finished!()
    }


    func executeCheckIfFinishedState(state: State, finished: (() -> Void)?)
    {
        self.currentState = state

        finished!()
    }


    func executeWaitForMoveState(state: State, finished: (() -> Void)?)
    {
        self.currentState = state
        self.isWaitingForMove = true
    }


    func executeMovingState(state: State, finished: (() -> Void)?)
    {
        self.currentState = state

        finished!()
    }


    func executeRemoveAfterMoveState(state: State, finished: (() -> Void)?)
    {
        self.currentState = state

        finished!()
    }


    func executeFinishedState(state: State, finished: (() -> Void)?)
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
                self.selectedMarble = nil
                self.moveMarble(selectedMarble, overFieldPath: path, finished: self.currentState!.nextState!.execute)
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
