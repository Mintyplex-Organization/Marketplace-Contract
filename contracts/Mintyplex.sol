// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IMintyplexDomains {
    struct Domain {
        address owner;
        string name;
        string image;
        string avatar;
        uint256 createdAt;
        bool enableSubDomains;
        uint256 expiry; // Add the expiry property to store the timestamp of domain's expiry
        uint256 noSubDomain;
    }

    function getDomainDetailsFromAddress(
        address _owner
    ) external view returns (Domain memory);
}

contract Mintyplex {
    enum ProductType {
        PHYSICAL,
        DIGITAL
    }
    enum Status {
        ACTIVE,
        INACTIVE
    }
    struct Creator {
        string name;
        bool isVerified;
        string mns;
        uint256 balance;
    }
    struct Product {
        string name;
        string date;
        string cid;
        uint256 sales;
        ProductType productType;
        uint256 price;
        Status status;
        string description;
        address owner;
    }

    IMintyplexDomains mns;

    constructor(address mintyplexDomain) {
        mns = IMintyplexDomains(mintyplexDomain);
    }
}
