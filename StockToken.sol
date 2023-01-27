// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IStockToken.sol";

/// @title StockToken
/// @dev   This is the Stock Token of the Reflection trading platform. Each StockToken is an ERC20 token and represents one stock on the stock exchange, so there will be many of these StockToken contracts deployed, each with a different namd and symbol
contract StockToken is ERC20, Ownable, ReentrancyGuard, IStockToken {
    address private refWalletAddress;
    address private rusdAddress;

    /// @dev    Access Modifier for methods that may only be called by the Reflection wallet
    modifier onlyRefWalletAddress() {
        require(msg.sender == refWalletAddress, "Only ref wallet");
        _;
    }

    /// @dev Access Modifier for methods that may only be called by the RUSD contract, which is the Reflection stablecoin
    modifier onlyRusdAddress() {
        require(msg.sender == rusdAddress, "Only RUSD");
        _;
    }

    /// @dev   Constructor
    /// @param __name (string)  Name of the ERC20 token
    /// @param __symbol (string)  Symbol of the ERC20 token
    /// @param _refWalletAddress (address)  Address of the Reflection wallet
    /// @param _rusdAddress (address)  Address of the RUSD Reflection stablecoin contract
    constructor(
        string memory __name,
        string memory __symbol,
        address _refWalletAddress,
        address _rusdAddress
    ) ERC20(__name, __symbol) {
        require(_refWalletAddress != address(0), "Zero Ref Address");
        require(_rusdAddress != address(0), "Zero RUSD Address");
        refWalletAddress = _refWalletAddress;
        rusdAddress = _rusdAddress;
    }

    /// @dev    Update the Reflection wallet address. This would most likely never be necessary, but it could be convenient to have this if we should ever want to use a different Reflection wallet
    /// @dev    Updating the ref wallet address
    /// @param _address (address)
    function setRefWalletAddress(address _address) external onlyOwner {
        require(_address != address(0), "Zero Ref Address");
        refWalletAddress = _address;
    }

    /// @dev    Update the RUSD address. RUSD is the Reflection stablecoin. This method would be called if we ever needed to update the RUSD smart contract.
    /// @param _address (address)
    function setRusdAddress(address _address) external onlyOwner {
        require(_address != address(0), "Zero RUSD Address");
        rusdAddress = _address;
    }

    /// @dev    Mint the StockToken into the user's wallet. This is called when the user buys a stock token on the Reflection platform.
    /// @param to (address)
    /// @param _amount (uint256)
    function mint(address to, uint256 _amount)
        external
        override
        onlyRusdAddress
    {
        _mint(to, _amount);
    }

    /// @dev    Burn the StockToken out of the user's wallet. This is done when the user sells a stock token on the Reflection platform.
    /// @param from (address)
    /// @param _amount (uint256)
    function burn(address from, uint256 _amount)
        external
        override
        onlyRusdAddress
    {
        _burn(from, _amount);
    }

    /// @dev    Function for buying this token using some stablecoin. This method is redundant with RUSD.buyStock() and will be removed.
    /// @param userAddress (address)
    /// @param stockTokenAmount (uint256)
    /// @param stableCoinAmount (uint256)
    /// @param stableCoinAddress (address)
    function buy(
        address userAddress,
        uint256 stockTokenAmount,
        uint256 stableCoinAmount,
        address stableCoinAddress
    ) external nonReentrant  {
        require(
            IERC20(stableCoinAddress).transferFrom(
                userAddress,
                refWalletAddress,
                stableCoinAmount
            ),
            "Transfer Failed"
        );
        _mint(userAddress, stockTokenAmount);
    }

    /// @dev    Function for selling the stock token. This method is redundant with RUSD.sellStock() and will be removed.
    /// @param userAddress (address)
    /// @param stockTokenAmount (uint256)
    /// @param stableCoinAmount (uint256)
    /// @param stableCoinAddress (address)
    function sell(
        address userAddress,
        uint256 stockTokenAmount,
        uint256 stableCoinAmount,
        address stableCoinAddress
    ) external nonReentrant  {
        _burn(userAddress, stockTokenAmount);

        require(
            IERC20(stableCoinAddress).transferFrom(
                refWalletAddress,
                userAddress,
                stableCoinAmount
            ),
            "Transfer Failed"
        );
    }
    
    /// @dev    Use default of 18 decimals
    /// @return (uint8) the number of decimal places for the ERC20 token
    function decimals() public pure override returns (uint8) {
        return 18;
    }

}
