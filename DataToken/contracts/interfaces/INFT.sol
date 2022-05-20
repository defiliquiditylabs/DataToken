pragma solidity 0.8.0;

interface INFT{
    function safeMint(string calldata name, address to ) external;
    function burn (bytes calldata tokenId) external;
}