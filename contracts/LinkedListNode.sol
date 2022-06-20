// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract LinkedListNode {

  struct Node{
    uint value;
    bytes32 next;
    bytes32 previous;
  }
}
