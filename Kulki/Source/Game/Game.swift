//
//  Game.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class State {
    var command: ((state: State, finished: (() -> Void)?) -> Void)!
    weak var nextState: State?

    func execute()
    {
        self.command(state: self, finished: self.nextState?.execute)
    }
}


class Game {
    internal(set) var view: UIView!
    internal var field: Field
    internal var currentState: State?
    private var states: [State]!


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

        self.showBoard()

        //finished!()
    }


    func executeSpawnState(state: State, finished: (() -> Void)?)
    {
        self.currentState = state

        finished!()
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

        finished!()
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
    func showBoard()
    {
        assert(false, "<<Abstract method>>")
    }
}
