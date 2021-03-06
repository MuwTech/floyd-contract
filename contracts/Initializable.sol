// SPDX-License-Identifier: ISC

pragma solidity >=0.6.0 <0.8.0;

contract Initializable {
    bool inited = false;

    modifier initializer() {
        require(!inited, "already inited");
        _;
        inited = true;
    }
}