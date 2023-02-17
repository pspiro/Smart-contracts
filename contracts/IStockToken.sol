// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IStockToken {
    /// @dev   Function to mint the stock token into the user's wallet; called by the Reflection wallet when the user
    ///        buys a stock token on the Reflection platform
    /// @param to The user's wallet address into which the StockToken will be minted
    /// @param _amount The number of StockTokens that will be minted into the user's wallet
    function mint(address to, uint256 _amount) external;

    /// @dev   Function to burn the stock token out of the user's wallet; called by the Reflection wallet when the user
    ///        sells a stock token on the Reflection platform
    /// @param from The user's wallet address from which the StockTokens will be burned
    /// @param _amount The number of StockTokens that will be burned out of the user's wallet
    function burn(address from, uint256 _amount) external;
}
