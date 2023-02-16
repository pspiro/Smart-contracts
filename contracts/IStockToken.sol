// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IStockToken {
    /// @dev    Function to mint the stock token into the user's wallet; called when the user buys a stock token on the Reflection platform
    /// @param to (address)
    /// @param _amount (uint256)
    function mint(address to, uint256 _amount) external;

    /// @dev    Function to burn the stock token out of the user's wallet; called when the user sells a stock token on the Reflection platform
    /// @param from (address)
    /// @param _amount (uint256)
    function burn(address from, uint256 _amount) external;
}
