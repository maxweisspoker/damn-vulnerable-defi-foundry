// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect SelfiePool abi)"
interface ISelfiePool {
    error CallbackFailed();
    error CallerNotGovernance();
    error RepayFailed();
    error UnsupportedCurrency();

    event FundsDrained(address indexed receiver, uint256 amount);

    function emergencyExit(address receiver) external;
    function flashFee(address _token, uint256) external view returns (uint256);
    function flashLoan(address _receiver, address _token, uint256 _amount, bytes memory _data)
        external
        returns (bool);
    function governance() external view returns (address);
    function maxFlashLoan(address _token) external view returns (uint256);
    function token() external view returns (address);
}
