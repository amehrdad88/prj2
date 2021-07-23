pragma solidity ^0.8.0;

//Importing openzeppelin-solidity ERC-721 implemented Standard
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// StarNotary Contract declaration inheritance the ERC721 openzeppelin implementation
contract StarNotary is ERC721("Star Notary Token", "SNT") { // ERC721 in latest version already implements name and symbol, had to change it to internal variables and call it here.

    // Star data
    struct Star {
        string name;
    }

    // Implement Task 1 Add a name and symbol properties
    // name: Is a short name to your token
    // symbol: Is a short string like 'USD' -> 'American Dollar'

    // This is already implemented in the OpenZeppelin ER721 implementation - see the contract inheritance call


    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;

    
    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sell the Star you don't own");
        approve(address(this), _tokenId); // If we don't do that the tests fail as the token was not approved to be transferred. Not sure if this is a security issue or not. 
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        require(_isApprovedOrOwner(address(this), _tokenId), "ERC721: transfer caller is not owner nor approved"); // checking that the contract is allowed to sell this token
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        _transfer(ownerAddress, msg.sender, _tokenId); // Transfer from owner to sender explicitly (do not use transferFrom as this function requires the buyer to be approved which cannot be known in advance)
        if(msg.value > starCost) {
            address payable senderAddressPayable = payable(msg.sender);
            senderAddressPayable.transfer(msg.value - starCost);
        }
    }

    // Implement Task 1 lookUptokenIdToStarInfo
    function lookUptokenIdToStarInfo(uint256 _tokenId) public view returns (string memory) {
        return tokenIdToStarInfo[_tokenId].name;
    }

    // Implement Task 1 Exchange Stars function
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        require(ownerOf(_tokenId1) == msg.sender || ownerOf(_tokenId2) == msg.sender, "You need to own one of the Stars");

        address owner1 = ownerOf(_tokenId1);
        address owner2 = ownerOf(_tokenId2);

        _transfer(owner1, owner2, _tokenId1); //transferFrom deos not work as owner1 needs to approve owner2 for this it seems in this implementation of ERC721 which is not practical in real life
        _transfer(owner2, owner1, _tokenId2); //transferFrom deos not work as owner1 needs to approve owner2 for this it seems in this implementation of ERC721 which is not practical in real life

    }

    // Implement Task 1 Transfer Stars
    function transferStar(address _to1, uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You need to own one of the Stars");
        _transfer(msg.sender, _to1, _tokenId);
    }

}