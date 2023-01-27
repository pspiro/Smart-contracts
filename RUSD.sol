// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IStockToken.sol";

/// @title RUSD
/// @dev   This is the Reflection stablecoin, similar to other stablecoins such as USDC and BUSD. It is backed 1-to-1 by a combination of US dollars and other stablecoins which in turn are backed by US dollars. RUSD can be used to buy Reflection stock tokens, and, likewise, stock tokens can be redeemed for RUSD. */
contract RUSD is ERC20, Ownable, ReentrancyGuard {
    address private refWalletAddress;

    /// @dev    Access Modifier for only Reflection wallet calls
    /// @param _refWalletAddress (address)  ref wallet address that will be calling the methods
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

    /// @dev    Update the ref wallet address. This would most likely never be necessary, but it could be convenient to have this if we should ever want to use a different Reflection wallet
    /// @param _refWalletAddress (address)
    function setRefWalletAddress(address _refWalletAddress) external onlyOwner {
        require(_refWalletAddress != address(0), "Zero Ref Address");
        refWalletAddress = _refWalletAddress;
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
            require(
                IERC20(_stableCoinAddress).transferFrom(
                    _userAddress,
                    refWalletAddress,
                    _stableCoinAmount
                ),
                "Transfer Failed"
            );
        }
        IStockToken(_stockTokenAddress).mint(_userAddress, _stockTokenAmount);
    }
    
    /// @dev    Called with the user sells a stock token on the Reflection platform. This method will (1) burn the stock token out of the user's wallet, and (2) either mint RUSD into their wallet, or transfer another stablecoin from the Reflection wallet to the user's wallet. The amount of stock tokens transacted are entered by the user on the platform. The amount of stablecoin is calculated by the platform based on the current market stock price.
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
            require(
                IERC20(_stableCoinAddress).transferFrom(
                    refWalletAddress,
                    _userAddress,
                    _stableCoinAmount
                ),
                "Transfer Failed"
            );
        }
        IStockToken(_stockTokenAddress).burn(_userAddress, _stockTokenAmount);
    }

    /// @dev    Called when the user elects to redeem their RUSD stablecoin for some other on the Reflection platform. We burn the RUSD out of the user's wallet and transfer the other stablecoin from the Reflection wallet to the user's wallet.
    /// @param _userAddress (address)
    /// @param _stableCoinAddress (address)
    /// @param _amount (uint256)
    function sellRUSD(
        address _userAddress,
        address _stableCoinAddress,
        uint256 _amount
    ) external nonReentrant onlyRefWalletAddress {
        // check stable.allowance(ref,rusd) >  ?: make ref approve
        _burn(_userAddress, _amount);
        require(
            IERC20(_stableCoinAddress).transferFrom(
                refWalletAddress,
                _userAddress,
                _amount
            ),
            "Transfer Failed"
        );
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
        require(
            IERC20(_stableCoinAddress).transferFrom(
                _userAddress,
                refWalletAddress,
                _amount
            ),
            "Transfer Failed"
        );
        _mint(_userAddress, _amount);
    }

    /// @dev    Modifying default decimals to 18
    /// @return  (uint8)
    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
