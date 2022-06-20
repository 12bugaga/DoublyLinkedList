// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./LinkedListNode.sol";

contract LinkedList {

  event Add(bytes32 nextId, bytes32 previousId, uint value);
  
  bytes32 public tailId; 
  bytes32 public headId; 
  mapping(bytes32 => LinkedListNode.Node) public nodes;
  uint public length = 0;

  bytes32 private NULL = 0x00; 

  function addAfter(uint afterValue, uint _value) public{
    bytes32 current = headId;
    bytes32 id;
    LinkedListNode.Node memory node;
    while(current != NULL){
      if(nodes[current].value == afterValue){
        if(nodes[current].next != NULL){
          node = LinkedListNode.Node(_value, nodes[current].next, current);
          id = keccak256(abi.encodePacked(node.value, node.previous));
          nodes[nodes[current].next].previous = id;
          nodes[current].next = id;
          nodes[id] = node;
          length++;
          return;
        }
        else
        {
          addLast(_value);
          return;
        }
      }
      current = nodes[current].next;
    }
    addLast(_value);
  }

  function addLast(uint _value) public {
    LinkedListNode.Node memory node = LinkedListNode.Node(_value, NULL, tailId);
    bytes32 currentId = keccak256(abi.encodePacked(node.value, node.previous));
    if(length == 0)
      headId = currentId;
    else
      nodes[tailId].next = currentId;
    
    tailId = currentId;
    nodes[currentId] = node;
    length++;
    emit Add(node.next, node.previous, node.value);
  }

  function addFirst(uint _value) public {
    LinkedListNode.Node memory node = LinkedListNode.Node(_value, headId, NULL);
    bytes32 currentId = keccak256(abi.encodePacked(node.value, node.previous));
    if(length == 0)
      tailId = currentId;
    else
      nodes[headId].previous = currentId;
    
    headId = currentId;
    nodes[currentId] = node;
    length++;
    emit Add(node.next, node.previous, node.value);
  }

  function remove(uint _value) public returns(bool){
    bytes32 current = headId;
    while(current != NULL){
      if(nodes[current].value == _value){
        // Middle or last element
        if(nodes[current].previous != NULL){
          nodes[nodes[current].previous].next = nodes[current].next;
          
          if(nodes[current].next == NULL) // Last elem
            removeLast();
          else{ // Middle elem
            nodes[nodes[current].next].previous = nodes[current].previous;
            delete nodes[current];
            length--;
          }
        }
        else
          removeFirst();
        return true;
      }
      current = nodes[current].next;
    }
    return false;
  }

  function removeFirst() public{
    if(length != 0){
      headId = nodes[headId].next;

      delete nodes[nodes[headId].previous];
      length--;

      if(length == 0)
        tailId = NULL;
      else
        nodes[headId].previous = NULL;
    }
  }

  function removeLast() public{
    if(length != 0){
      tailId = nodes[tailId].previous;

      delete nodes[nodes[tailId].next];
      length--;

      if(length == 0)
        headId = NULL;
      else
        nodes[tailId].next = NULL;
    }
  }

  function contain(uint _value) public view returns(bool){
    bytes32 current = headId;
    while(current != NULL){
      if(nodes[current].value == _value)
        return true;
      
      current = nodes[current].next;
    }
    return false;
  }
  
  function clear() public {
    bytes32 current = headId;
    bytes32 next;
    while(current != NULL){
      next = nodes[current].next;
      delete nodes[current];
      current = next;
    }
    headId = NULL;
    tailId = NULL;
    length = 0;
  }

  function getValues() public view returns(string memory){
    bytes32 current = headId;
    string memory result;
    string memory temp;
    while(current != NULL){
      LinkedListNode.Node storage node = nodes[current];
      temp = uint2str(node.value);
      result = string(abi.encodePacked(result, temp, " "));
      current = nodes[current].next;
    }
    return result;
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
