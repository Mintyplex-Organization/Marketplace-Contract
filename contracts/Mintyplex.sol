// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./libraries/base64.sol";

error RangeOutbond();
error ErrorCreatingProduct();
error NotOwner();
error ProductDoesnotExist();

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

contract Mintyplex is ERC721URIStorage {
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
        uint256 id;
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
    uint256 productCounter = 0;

    mapping(uint256 => Product) private idToProduct;
    mapping(address => uint256[]) private userProductCounter;
    mapping (address => uint256) private balance;

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
    modifier verifyProduct(uint256 _id) {
        Product storage product = idToProduct[_id];
        if (product.date == 0) {
            revert ProductDoesnotExist();
        }
        _;
    }
    modifier isOwner(uint256 _productId) {
        Product storage product = idToProduct[_productId];
        if (product.owner != msg.sender) {
            revert NotOwner();
        }
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

        Product storage product = idToProduct[productCounter];
        product.id = productCounter;
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

        bool responds = _createProduct(
            _name,
            _description,
            _cid,
            _attribute,
            _value
        );
        if (responds) {
            userProductCounter[msg.sender].push(productCounter);
            productCounter++;

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

    function _createProduct(
        string memory _name,
        string memory _description,
        string memory _cid,
        string[] calldata _attribute,
        string[] calldata _value
    ) private returns (bool) {
        uint256 id = productCounter;
        _safeMint(msg.sender, id);
        string memory uri = createUri(
            _name,
            _description,
            _cid,
            _attribute,
            _value
        );
        _setTokenURI(id, uri);
        return true;
    }

    function createUri(
        string memory _name,
        string memory _description,
        string memory _cid,
        string[] calldata _attribute,
        string[] calldata _value
    ) private view returns (string memory) {
        string memory json;
        json = Base64.encode(
            abi.encodePacked(
                "{"
                '"name": "',
                _name,
                '", '
                '"description": "',
                _description,
                '", '
                '"owner": "',
                msg.sender,
                '", '
                '"product": "ipfs://',
                _cid,
                '", '
                '"properties": ['
            )
        );

        for (uint i = 0; i < _attribute.length; i++) {
            json = string(
                abi.encodePacked(
                    json,
                    '{"attribute": "',
                    _attribute[i],
                    '", "value": "',
                    _value[i],
                    '"}'
                )
            );
            if (i < _attribute.length - 1) {
                json = string(abi.encodePacked(json, ", "));
            }
        }

        json = string(abi.encodePacked(json, "]}"));
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return finalTokenUri;
    }

    function editProduct(
        uint256 _id,
        string[] memory _thumbnails,
        uint256 newPrice
    ) external verifyProduct(_id) isOwner(_id) {
        Product storage product = idToProduct[_id];
        product.price = newPrice;
        product.thumbnails = _thumbnails;
    }

    function buyProduct(
        uint256 _id,
        uint256 _quantity,
        address buyer
    ) external payable verifyProduct(_id) {
        Product storage product = idToProduct[_id];
        
    }

    function deleteProduct(
        uint256 _id
    ) external verifyProduct(_id) isOwner(_id) {
        Product storage product = idToProduct[_id];
        product.id = productCounter;
        product.thumbnails = [""];
        product.name = "";
        product.date = 0;
        product.cid = "";
        product.sales = 0;
        product.quantity = 0;
        product.productType = "";
        product.price = 0;
        product.isActive = false;
        product.description = "";
        product.owner = msg.sender;
        product.referral = false;
        product.referralPercentage = 0;
        product.attribute = [""];
        product.value = [""];
    }

    function changeVisibility(
        uint256 _id
    ) external verifyProduct(_id) isOwner(_id) {
        Product storage product = idToProduct[_id];
        product.isActive = !product.isActive;
    }

    function getAllProduct() external view returns (Product[] memory) {
        Product[] memory allProduct = new Product[](productCounter);
        for (uint256 i = 0; i < productCounter; i++) {
            Product storage product = idToProduct[i];
            allProduct[i] = product;
        }
        return allProduct;
    }

    function getAllUsersProduct(
        address _owner
    ) external view returns (Product[] memory) {
        uint256[] memory ids = userProductCounter[_owner];
        Product[] memory userProduct = new Product[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            Product storage product = idToProduct[ids[i]];
            userProduct[i] = product;
        }
        return userProduct;
    }
}
