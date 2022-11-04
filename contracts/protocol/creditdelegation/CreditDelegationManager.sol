// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract CreditDelegationManager is ERC721, ERC721Burnable, Ownable {
  using Counters for Counters.Counter;

  uint256 public transferRate = 0.01 ether;

  Counters.Counter private _tokenIdCounter;

  struct ZeruSmartCard {
    uint256 tokenId;
    address owner;
    string[][] assetBalances;
  }
  mapping(uint256 => ZeruSmartCard) private tokenIdToSmartCard;
  mapping(address => uint256[]) private ownerToTokenId;

  constructor() ERC721('ZeruSmartCard', 'ZSC') {}

  function _baseURI() internal pure override returns (string memory) {
    return 'ipfs://';
  }

  function safeMint(string memory _tokenURI, uint256 _price) public payable {
    //require(msg.value >= mintRate,"Not enough ether");

    //initialize _assetAndBalance variable here
    string[][] _assetAndBalance;

    // before burning the credit tokens of the user
    // they are stored in structure variable for minting creditTokens in the future

    //burn the credit tokens here after storing in data in _assetAndBalance variable
    // write burning code here ----

    // ----------------------------

    // increment token id and store it in tokenId
    _tokenIdCounter.increment();
    uint256 tokenId = _tokenIdCounter.current();

    // mint the nft for the msg.sender
    _safeMint(msg.sender, tokenId);

    //add newly minted token minters list
    ownerToTokenId[msg.sender].push(tokenId);

    // _assetAndBalance are stored in ZeruSmartCard structure
    tokenIdToSmartCard[tokenId] = ZeruSmartCard(tokenId, msg.sender, _assetAndBalance);
  }

  function getAssetBalances(uint256 _tokenId) public view returns (string[][] memory) {
    return tokenIdToSmartCard[_tokenId].assetBalances;
  }

  function getTokenIdFromAddress() public view returns (uint256[] memory) {
    return ownerToTokenId[msg.sender];
  }

  function delegateCredit(address to, uint256 tokenId) public payable {
    require(msg.value >= transferRate, 'Fee required to transfer is 0.01');
    _transfer(msg.sender, to, tokenId);
  }

  function withdraw() public onlyOwner {
    require(address(this).balance > 0, 'Balance is 0');
    payable(owner()).transfer(address(this).balance);
  }
}
