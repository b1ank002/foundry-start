// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {SimpleTodoList} from "../src/ToDoList.sol";

contract ToDoListTest is Test {
    SimpleTodoList toDoListContract;

    function setUp() public {
        toDoListContract = new SimpleTodoList();
    }

    function test_AddTask(address _account, address _account1) public {
        // Arange
        string memory _text = "Add the flour";
        string memory _text1 = "Break an egg";
        string memory _text2 = "Pour milk";
        string memory _text3 = "A pinch of salt";

        // Act
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskAdded(_account, 0, _text);
        vm.prank(_account);
        toDoListContract.addTask(_text);

        vm.startPrank(_account1);
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskAdded(_account1, 0, _text1);
        toDoListContract.addTask(_text1);
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskAdded(_account1, 1, _text2);
        toDoListContract.addTask(_text2);
        SimpleTodoList.Task[] memory tasks = toDoListContract.getMyTasks();
        vm.stopPrank();

        vm.startPrank(_account);
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskAdded(_account, 1, _text3);
        toDoListContract.addTask(_text3);
        SimpleTodoList.Task[] memory tasks1 = toDoListContract.getMyTasks();
        vm.stopPrank();

        // Assert
        assertEq(tasks.length, 2);
        assertEq(tasks[0].text, _text1);
        assertFalse(tasks[0].isDone);
        assertEq(tasks[1].text, _text2);
        assertFalse(tasks[1].isDone);

        assertEq(tasks1.length, 2);
        assertEq(tasks1[0].text, _text);
        assertFalse(tasks1[0].isDone);
        assertEq(tasks1[1].text, _text3);
        assertFalse(tasks1[1].isDone);
    }

    function test_UpdateTask(address _account) public {
        // Arange
        string memory _text = "Make a cake";
        string memory _text1 = "Go to study solidity";
        string memory empty = "";

        // Act
        vm.startPrank(_account);
        toDoListContract.addTask(_text);
        SimpleTodoList.Task[] memory tasks = toDoListContract.getMyTasks();
        console.log(tasks.length);
        console.log(tasks[0].text);

        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskUpdated(_account, 0, _text1);
        toDoListContract.updateTask(0, _text1);
        tasks = toDoListContract.getMyTasks();
        console.log(tasks[0].text);

        // update to the same text
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskUpdated(_account, 0, _text1);
        toDoListContract.updateTask(0, _text1);
        tasks = toDoListContract.getMyTasks();
        console.log(tasks[0].text);

        // update to the empty string
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskUpdated(_account, 0, empty);
        toDoListContract.updateTask(0, empty);
        tasks = toDoListContract.getMyTasks();
        console.log(tasks[0].text);
        vm.stopPrank();

        // catch error
        vm.expectRevert(bytes("Invalid task index"));
        toDoListContract.updateTask(1, _text1);

        vm.stopPrank();

        // Assert
        assertEq(tasks.length, 1);
        assertEq(tasks[0].text, empty);
        assertFalse(tasks[0].isDone);
    }

    function test_completeTask(address _account) public {
        // Arange
        string memory _text = "Go to study solidity";

        // Act
        vm.startPrank(_account);
        toDoListContract.addTask(_text);
        SimpleTodoList.Task[] memory tasks = toDoListContract.getMyTasks();
        console.log(tasks.length);
        console.log(tasks[0].text);

        // cach error
        vm.expectRevert(bytes("Invalid task index"));
        toDoListContract.completeTask(1);

        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskCompleted(_account, 0);
        toDoListContract.completeTask(0);
        tasks = toDoListContract.getMyTasks();
        console.log(tasks[0].text);

        //complete the same task second time
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskCompleted(_account, 0);
        toDoListContract.completeTask(0);
        tasks = toDoListContract.getMyTasks();
        console.log(tasks[0].text);

        vm.stopPrank();

        // Assert
        assertEq(tasks.length, 1);
        assertEq(tasks[0].text, _text);
        assertTrue(tasks[0].isDone);
    }

    function test_DeleteTask(address _account) public {
        // Arange
        string memory _text = "Go to study solidity";
        string memory _text1 = "Make a cake";

        // Act
        vm.startPrank(_account);
        toDoListContract.addTask(_text);
        toDoListContract.addTask(_text1);
        SimpleTodoList.Task[] memory tasks = toDoListContract.getMyTasks();
        console.log(tasks.length);
        console.log(tasks[0].text);
        console.log(tasks[1].text);

        // cach error
        vm.expectRevert(bytes("Invalid task index"));
        toDoListContract.deleteTask(2);

        // if task does not complete
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskDeleted(_account, 0);
        toDoListContract.deleteTask(0);
        tasks = toDoListContract.getMyTasks();
        console.log(tasks.length);
        console.log(tasks[0].text);

        // if task complete
        toDoListContract.completeTask(0);
        vm.expectEmit(true, false, false, true);
        emit SimpleTodoList.TaskDeleted(_account, 0);
        toDoListContract.deleteTask(0);
        tasks = toDoListContract.getMyTasks();
        console.log(tasks.length);
        vm.stopPrank();

        // Assert
        assertEq(tasks.length, 0);
    }
}