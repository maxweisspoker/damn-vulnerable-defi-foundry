// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect ITrustfulOracle abi)"
interface ITrustfulOracle {
    error NotEnoughSources();

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event UpdatedPrice(address indexed source, string indexed symbol, uint256 oldPrice, uint256 newPrice);

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function INITIALIZER_ROLE() external view returns (bytes32);
    function MIN_SOURCES() external view returns (uint256);
    function TRUSTED_SOURCE_ROLE() external view returns (bytes32);
    function getAllPricesForSymbol(string memory symbol) external view returns (uint256[] memory prices);
    function getMedianPrice(string memory symbol) external view returns (uint256);
    function getPriceBySource(string memory symbol, address source) external view returns (uint256);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
    function grantRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function postPrice(string memory symbol, uint256 newPrice) external;
    function renounceRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function setupInitialPrices(address[] memory sources, string[] memory symbols, uint256[] memory prices) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
