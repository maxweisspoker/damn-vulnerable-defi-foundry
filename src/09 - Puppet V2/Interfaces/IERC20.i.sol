// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

// This is modified slightly from the original challenge to include more ERC20
// functionality. The PuppetV2 contract doesn't use the addtional functionality,
// so it doesn't change the challenge. However, because of the use of the
// fixed older solidity compiler version, the test files that need an IERC20
// import can't use the normal openzeppelin contracts (which require solidity 0.8).
// Therefore I've made the test use this interface below for IERC20, which is why
// the additional functionality was added.
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
