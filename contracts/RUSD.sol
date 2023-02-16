// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IStockToken.sol";

/// @title RUSD
/// @dev   This is the Reflection stablecoin, similar to other stablecoins such as USDC and BUSD. It is backed 1-to-1 by a combination of US dollars and other stablecoins which in turn are backed by US dollars. RUSD can be used to buy Reflection stock tokens, and, likewise, stock tokens can be redeemed for RUSD. */
contract RUSD is ERC20, Ownable, ReentrancyGuard {
    address public refWalletAddress;
    using SafeERC20 for IERC20;
    /// @dev    Access Modifier for methods that may only be called by the Reflection wallet
    modifier onlyRefWalletAddress() {
        require(msg.sender == refWalletAddress, "Only ref wallet");
        _;
    }

    /// @dev    Constructor
    /// @param _refWalletAddress (address)  Reflection wallet address that will be calling the methods
    constructor(address _refWalletAddress) ERC20("Reflection USD Stablecoin", "RUSD") {
        require(_refWalletAddress != address(0), "Zero Ref Address");
        refWalletAddress = _refWalletAddress;
    }

    // events 

    event SetRefWalletAddress(address RefWalletAddress);
    event BuyStock(address UserAddress,
        address StableCoinAddress,
        address StockTokenAddress,
        uint256 StableCoinAmount,
        uint256 StockTokenAmount);
    event SellStock(
        address UserAddress,
        address StableCoinAddress,
        address StockTokenAddress,
        uint256 StableCoinAmount,
        uint256 StockTokenAmount
    );
    event SellRusd(
        address UserAddress,
        address StableCoinAddress,
        uint256 Amount
    );
    event BuyRusd(
        address UserAddress,
        address StableCoinAddress,
        uint256 Amount
    );
    /// @dev    Update the ref wallet address. This would most likely never be necessary, but it could be convenient to have this if we should ever want to use a different Reflection wallet
    /// @param _refWalletAddress (address)
    function setRefWalletAddress(address _refWalletAddress) external onlyOwner {
        require(_refWalletAddress != address(0), "Zero Ref Address");
        refWalletAddress = _refWalletAddress;
        emit SetRefWalletAddress(_refWalletAddress);
    }

    /// @dev   Mint RUSD into the user's wallet. This is done when the user sells a stock token on the Reflection platform.
    /// @param to (address)
    /// @param _amount (uint256)
    function mint(address to, uint256 _amount) external onlyRefWalletAddress {
        _mint(to, _amount);
    }

    /// @dev    Burn RUSD out of the user's wallet. This is done when the user buys a Stock Token and wants to pay with RUSD which they obtained from a previous sale. They must acknowledge a confirmation dialog before this method will be called. 
    /// @param from (address)
    /// @param _amount (uint256)
    function burn(address from, uint256 _amount) external onlyRefWalletAddress {
        _burn(from, _amount);
    }

    /// @dev    Called when the user buys a stock token on the Reflection platform. This method will (1) mint the stock token into the user's wallet, and (2) either burn RUSD out of their wallet (if they are paying with RUSD), or transfer another stablecoin (such as BUSD) from their wallet to the Reflection wallet (if they are not paying with RUSD). The amount of stock tokens transacted are entered by the user on the platform. The amount of stablecoin is calculated by the platform based on the current market stock price.
    /// @param _userAddress (address)
    /// @param _stableCoinAddress (address)
    /// @param _stockTokenAddress (address)
    /// @param _stableCoinAmount (uint256)
    /// @param _stockTokenAmount (uint256)
    function buyStock(
        address _userAddress,
        address _stableCoinAddress,
        address _stockTokenAddress,
        uint256 _stableCoinAmount,
        uint256 _stockTokenAmount
    ) external nonReentrant onlyRefWalletAddress {
        if (_stableCoinAddress == address(this)) {
            _burn(_userAddress, _stableCoinAmount);
        } else {
            
                IERC20(_stableCoinAddress).safeTransferFrom(
                    _userAddress,
                    refWalletAddress,
                    _stableCoinAmount
                );
        }
        IStockToken(_stockTokenAddress).mint(_userAddress, _stockTokenAmount);
        emit BuyStock(_userAddress,_stableCoinAddress, _stockTokenAddress,_stableCoinAmount, _stockTokenAmount);
    }
    
    /// @dev    Called when the user sells a stock token on the Reflection platform. This method will (1) burn the stock token out of the user's wallet, and (2) either mint RUSD into their wallet, or transfer another stablecoin from the Reflection wallet to the user's wallet. The amount of stock tokens transacted are entered by the user on the platform. The amount of stablecoin is calculated by the platform based on the current market stock price.
    /// @param _userAddress (address)
    /// @param _stableCoinAddress (address)
    /// @param _stockTokenAddress (address)
    /// @param _stableCoinAmount (uint256)
    /// @param _stockTokenAmount (uint256)
    function sellStock(
        address _userAddress,
        address _stableCoinAddress,
        address _stockTokenAddress,
        uint256 _stableCoinAmount,
        uint256 _stockTokenAmount
    ) external nonReentrant onlyRefWalletAddress {
        if (_stableCoinAddress == address(this)) {
            _mint(_userAddress, _stableCoinAmount);
        } else {
                
                IERC20(_stableCoinAddress).safeTransferFrom(
                    refWalletAddress,
                    _userAddress,
                    _stableCoinAmount
                );
        }
        IStockToken(_stockTokenAddress).burn(_userAddress, _stockTokenAmount);
        emit SellStock(_userAddress,_stableCoinAddress,_stockTokenAddress,_stableCoinAmount,_stockTokenAmount);
    }

    /// @dev    Called when the user elects to redeem (sell) their RUSD stablecoin for some other stablecoin on the Reflection platform. We burn the RUSD out of the user's wallet and transfer the other stablecoin from the Reflection wallet to the user's wallet.
    /// @param _userAddress (address)
    /// @param _stableCoinAddress (address)
    /// @param _amount (uint256)
    function sellRusd(
        address _userAddress,
        address _stableCoinAddress,
        uint256 _amount
    ) external nonReentrant onlyRefWalletAddress {
        // check stable.allowance(ref,rusd) >  ?: make ref approve
        _burn(_userAddress, _amount);
            IERC20(_stableCoinAddress).safeTransferFrom(
                refWalletAddress,
                _userAddress,
                _amount
            );
        emit SellRusd(_userAddress,_stableCoinAddress,_amount);
    }

    /// @dev    Function for buying RUSD stablecoin. Currently this method is never called, but we're leaving our options open for the future. This method mints RUSD into the user's wallet and transfers the other stablecoin from their wallet to the Reflection wallet.
    /// @param _userAddress (address)
    /// @param _stableCoinAddress (address)
    /// @param _amount (uint256)
    function buyRusd(
        address _userAddress,
        address _stableCoinAddress,
        uint256 _amount
    ) external nonReentrant onlyRefWalletAddress {
        
            IERC20(_stableCoinAddress).safeTransferFrom(
                _userAddress,
                refWalletAddress,
                _amount
            );
        _mint(_userAddress, _amount);
        emit BuyRusd(_userAddress,_stableCoinAddress,_amount); 
    }

}
