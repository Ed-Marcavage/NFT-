pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => uint256) public requestIdToTokenId;

    event RequestedCollectible(bytes32 indexed requestId);
    event ReturnedCollectible(bytes32 indexed requestId, uint256 randomNumber);
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public tokenCounter;

    constructor(
        address _VRFCoordinator,
        address _LinkToken,
        bytes32 _keyhash
    )
        public
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("Dogie", "DOG")
    {
        tokenCounter = 0;
        keyHash = _keyhash;
        fee = 0.1 * 10**18;
    }

    function createCollectible(string memory tokenURI)
        public
        returns (bytes32)
    {
        // requestId is returned from Chainlink requestRandomness function
        bytes32 requestId = requestRandomness(keyHash, fee);
        // Mapp sender to their Link requestId
        requestIdToSender[requestId] = msg.sender;
        // Mapp Token URI to their Link requestId
        requestIdToTokenURI[requestId] = tokenURI;
        // For testing
        emit RequestedCollectible(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        // retreives dogOwner based on Link requestId
        address dogOwner = requestIdToSender[requestId];
        // retreives tokenURI based on Link requestId
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;
        // Mints new NFT ->  _safeMint(address to, uint256 tokenId) in ERC 721
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        Breed breed = Breed(randomNumber % 3);
        // Maps token ID to the tokens breed
        tokenIdToBreed[newItemId] = breed;
        // Maps requestId to th token ID
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
        emit ReturnedCollectible(requestId, randomNumber);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}
