// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error RangeOutbond();
error ErrorCreatingProduct();

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

contract Mintyplex is ERC721 {
    // enum ProductType {
    //     PHYSICAL,
    //     DIGITAL
    // }
    // enum Status {
    //     ACTIVE,
    //     INACTIVE
    // }
    struct Creator {
        string name;
        bool isVerified;
        string mns;
        uint256 balance;
    }
    struct Product {
        string[] thumbnails;
        string name;
        uint256 date;
        string cid;
        uint256 sales;
        uint256 quantity;
        string productType;
        uint256 price;
        bool isActive;
        string description;
        address owner;
        bool referral;
        uint256 referralPercentage;
        string[] attribute;
        string[] value;
    }

    IMintyplexDomains mns;
    uint256 totalProduct = 0;

    mapping(address => mapping(uint256 => Product)) public ownersProduct;
    mapping(address => uint256) public productCount; // Total number of product by a user
    mapping(uint256 => address) productIdToOwner;

    event ProductCreated(
        string[] _thumbnails,
        string _name,
        uint256 indexed _quantity,
        string _productType,
        uint256 indexed _productPrice,
        bool _referral,
        uint256 _referralPercentage,
        string _description,
        string _cid,
        string[] _attribute,
        string[] _value,
        address indexed _owner
    );
    modifier verifyProduct(uint256 id) {
        _;
    }

    constructor(address mintyplexDomain) ERC721("Mintyplex", "MTPX") {
        mns = IMintyplexDomains(mintyplexDomain);
    }

    function createProduct(
        string[] calldata _thumbnails,
        string calldata _name,
        uint256 _quantity,
        string calldata _productType,
        uint256 _productPrice,
        bool _referral,
        uint256 _referralPercentage,
        string calldata _description,
        string calldata _cid,
        string[] calldata _attribute,
        string[] calldata _value
    ) internal {
        //errors
        if (_attribute.length != _value.length) {
            revert RangeOutbond();
        }

        uint256 numProduct = productCount[msg.sender];
        Product storage product = ownersProduct[msg.sender][numProduct];

        product.thumbnails = _thumbnails;
        product.name = _name;
        product.date = block.timestamp;
        product.cid = _cid;
        product.sales = 0;
        product.quantity = _quantity;
        product.productType = _productType;
        product.price = _productPrice;
        product.isActive = true;
        product.description = _description;
        product.owner = msg.sender;
        product.referral = _referral;
        product.referralPercentage = _referralPercentage;
        product.attribute = _attribute;
        product.value = _value;

        productCount[msg.sender] = numProduct + 1;
        bool responds = _createProduct();
        if (responds) {
            emit ProductCreated(
                _thumbnails,
                _name,
                _quantity,
                _productType,
                _productPrice,
                _referral,
                _referralPercentage,
                _description,
                _cid,
                _attribute,
                _value,
                msg.sender
            );
        } else {
            revert ErrorCreatingProduct();
        }
    }

    function _createProduct() private returns (bool) {
        uint256 id = totalProduct;
        productIdToOwner[id] = msg.sender;
        totalProduct++;
        _safeMint(msg.sender, id);
        string memory uri = createUri();
        _setTokenURI(id, uri);
        return true;
    }

    function createUri() private returns (string memory) {}

    // function editProduct(uint256 _id, string[] calldata _thumbnail, ) external{}
    function deleteProduct() external {}

    function deactivateProduct() external {}

    function activateProduct() external {}
}
