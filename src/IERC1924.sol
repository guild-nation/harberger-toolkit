// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC1924 {
    function mint(uint256 valuation) external payable returns (uint256);
    function foreclose(uint256 tokenId) external;
    function acquire(uint256 tokenId, uint256 valuation) external payable;
    function updateValuation(uint256 tokenId, uint256 valuation) external payable;
    function deposit(address recipient) external payable;
    function withdraw(uint256 amount) external returns (bool);
    function collectTax(address patron) external;
    function withdrawBenefactor() external returns (bool);
}
