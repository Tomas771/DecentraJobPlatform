// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract JobContract {
    uint public id;
    bytes32 public name;
    address public publisher;
    uint public founded_amount;
    address public contractor;
    State public state;

    enum State {
        IN_PROGRESS,
        RESOLVED,
        CLOSED,
        CANCELLED
    }

    constructor(
        uint256 _id,
        bytes32 _name,
        address _contractor
    ) payable {
        id = _id;
        name = _name;
        publisher = msg.sender;
        founded_amount = msg.value;
        contractor = _contractor;
        state = State.IN_PROGRESS;
    }

    function resolve() public {
        require(msg.sender == contractor && state == State.IN_PROGRESS);
        state = State.RESOLVED;
    }

    function approveCompletion() public {
        require(msg.sender == publisher && state == State.RESOLVED);

        (bool callSuccess, ) = payable(contractor).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");

        state = State.CLOSED;
    }

    function cancelContract() public {
        require(msg.sender == contractor || msg.sender == publisher);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");

        state = State.CANCELLED;
    }
}
