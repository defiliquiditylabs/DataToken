
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC.sol";
import "./Dependencies/Ownable.sol";

contract MyToken is ERC, Ownable {
    uint id=0;

    event profileCreated(bytes tokenId, address owner, string name, uint time);

    constructor() ERC("MyToken", "MTK") {}

    function safeMint(string calldata name, address to ) public  {
        id++;
        uint time=block.timestamp;
        bytes memory newtokenId=(abi.encode(name, to, id, time));
        _safeMint(to, newtokenId);
        
    }

    function burn (bytes calldata tokenId) public {
        _burn(tokenId);
    }




    function onERCReceived(
        address,
        address from,
        bytes32,
        bytes calldata
    ) external pure returns (bytes4) {
      require(from == address(0x0), "Cannot send nfts to Vault directly");
      return IERCReceiver.onERCReceived.selector;
    }

    function decode(bytes memory data) public pure returns (string memory name, address to, uint _id, uint time) {
        (name, to, _id, time) = abi.decode(data, (string, address, uint, uint));            
    }
}