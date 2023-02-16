// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BUSD is ERC20, Ownable, ReentrancyGuard {
    address public refWalletAddress;
    
    
    /// @dev    Access Modifier for only ref wallet calls
    modifier onlyRefWalletAddress() {
        require(msg.sender == refWalletAddress, "Only ref wallet");
        _;
    }
    /// @dev
    /// @param _refWalletAddress (address)  ref wallet address that will be calling the contracts

    constructor(address _refWalletAddress) ERC20("Reflection BUSD", "RBUSD") {
        require(_refWalletAddress != address(0), "Zero Ref Address");
        refWalletAddress = _refWalletAddress;
    }
    
    event SetRefWalletAddress(address RefWalletAddress);

    /// @dev    Updating the ref wallet address
    /// @param _refWalletAddress (address)
    function setRefWalletAddress(address _refWalletAddress) external onlyOwner {
        require(_refWalletAddress != address(0), "Zero Ref Address");
        refWalletAddress = _refWalletAddress;
         emit SetRefWalletAddress(_refWalletAddress);
    }

    /// @dev    Mint function if there's not enough RUSD supply
    /// @param to (address)
    /// @param _amount (uint256)

    function mint(address to, uint256 _amount) external onlyRefWalletAddress {
        _mint(to, _amount);
    }

    /// @dev    Burn function to burn out Tokens
    /// @param from (address)
    /// @param _amount (uint256)
    function burn(address from, uint256 _amount) external onlyRefWalletAddress {
        _burn(from, _amount);
    }

    /// @dev    Modifying default decimals to 18
    /// @return  (uint8)
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
