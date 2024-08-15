// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {
    struct Todo {
        string name;
        bool isCompleted;
    }

    Todo[] public list;

    event TaskCreated(uint256 index, string name);
    event TaskNameUpdated(uint256 index, string newName);
    event TaskStatusUpdated(uint256 index, bool isCompleted);
    event TaskDeleted(uint256 index);

    // 创建任务
    function create(string memory name_) external {
        list.push(Todo({
            name: name_,
            isCompleted: false
        }));
        emit TaskCreated(list.length - 1, name_);
    }

    // 修改任务名称
    function modiName1(uint256 index_, string memory name_) external {
        list[index_].name = name_;
        emit TaskNameUpdated(index_, name_);
    }

    function modiName2(uint256 index_, string memory name_) external {
        Todo storage temp = list[index_];
        temp.name = name_;
        emit TaskNameUpdated(index_, name_);
    }

    // 修改完成状态1:手动指定完成或者未完成
    function modiStatus1(uint256 index_, bool status_) external {
        list[index_].isCompleted = status_;
        emit TaskStatusUpdated(index_, status_);
    }

    // 修改完成状态2:自动切换 toggle
    function modiStatus2(uint256 index_) external {
        list[index_].isCompleted = !list[index_].isCompleted;
        emit TaskStatusUpdated(index_, list[index_].isCompleted);
    }

    // 删除任务
    function deleteTask(uint256 index_) external {
        require(index_ < list.length, "Index out of bounds");
        for (uint256 i = index_; i < list.length - 1; i++) {
            list[i] = list[i + 1];
        }
        list.pop();
        emit TaskDeleted(index_);
    }

    // 获取任务
    function get(uint256 index_) external view returns (string memory name_, bool status_) {
        Todo storage temp = list[index_];
        return (temp.name, temp.isCompleted);
    }
}
