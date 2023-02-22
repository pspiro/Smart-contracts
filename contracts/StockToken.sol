// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IStockToken.sol";

/// @title StockToken
/// @dev   This is the Stock Token of the Reflection trading platform. Each StockToken is an ERC20 token and represents
///        one stock on the stock exchange, so there will be many of these StockToken contracts deployed, each with a
///        different namd and symbol
contract StockToken is ERC20, Ownable, ReentrancyGuard, IStockToken {
    address public rusdAddress;
    using SafeERC20 for IERC20;

    /// @dev Access Modifier for methods that may only be called by the RUSD contract, which is the Reflection
    ///      stablecoin
    modifier onlyRusdAddress() {
        require(msg.sender == rusdAddress, "Only RUSD");
        _;
    }

    /// @dev   Constructor
    /// @param __name (string)  Name of the ERC20 token
    /// @param __symbol (string)  Symbol of the ERC20 token
    /// @param _rusdAddress (address)  Address of the RUSD Reflection stablecoin contract
    constructor(string memory __name, string memory __symbol, address _rusdAddress) ERC20(__name, __symbol) {
        require(_rusdAddress != address(0), "Zero RUSD Address");
        rusdAddress = _rusdAddress;
    }

    // events
    event SetRusdAddress(address RusdAddress);


    /// @dev   Update the RUSD address. RUSD is the Reflection stablecoin. This method would be called if we ever
    ///        needed to update the RUSD smart contract.
    /// @param _address The new contract address of the RUSD contract
    function setRusdAddress(address _address) external onlyOwner {
        require(_address != address(0), "Zero RUSD Address");
        rusdAddress = _address;
        emit SetRusdAddress(_address);
    }

    /// @dev   Mint the StockToken into the user's wallet. This is called when the user buys a stock token on the
    ///        Reflection platform. It is called from (and only from) the RUSD contract.
    /// @param to The wallet address to which the StockToken will be minted
    /// @param _amount The number of StockTokens which will be minted
    function mint(address to, uint256 _amount) external override onlyRusdAddress {
        _mint(to, _amount);
    }

    /// @dev   Burn the StockToken out of the user's wallet. This is done when the user sells a stock token on the
    ///        Reflection platform. It is called from (and only from) the RUSD contract.
    /// @param from The wallet address from which the StockTokens will be burned
    /// @param _amount The number of StockTokens which will be burned
    function burn(address from, uint256 _amount) external override onlyRusdAddress {
        _burn(from, _amount);
    }
}
