pragma solidity ^0.8.0;

import "@openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/payment/PaymentSplitter.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


import "./ContentMixin.sol";
import "./Nt.sol";
import "./ClaimableWithSvin.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @dev Contract module which allows to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract FloydMinting is ERC721Enumerable {
    function _mintFloyd(address owner, uint256 startingIndex, uint16 number) internal {
        for (uint i = 0; i < number; i++) {
            _safeMint(owner, startingIndex + i);
        }
    }
}

abstract contract FloydSelling is FloydMinting, Pausable, ContextMixin, NativeMetaTransaction {
    uint256 constant maxFloyd = 9840;
    uint constant sellableFloydStartingIndex = 600;
    uint constant giveawayFloydStartingIndex = 20;
    uint constant specialFloydStartingIndex  = 1;
    uint16 constant maxFloydToBuyAtOnce = 10;

    uint constant singleFloydPrice = 45100000 gwei;  //price to be set

    uint256 public nextFloydForSale;
    uint public nextFloydToGiveaway;
    uint public nextSpecialFloyd;

    constructor() {
        nextFloydForSale = sellableFloydStartingIndex;
        nextFloydToGiveaway = giveawayFloydStartingIndex;
        nextSpecialFloyd    = specialFloydStartingIndex;
        // initSvinBalances();
    }

    // function claimFloyd() public {
    //     uint16 FloydsToMint = howManyFreeFloyds();

    //     require(FloydsToMint > 0, "You cannot claim Floyd tokens");
    //     require(leftForSale() >= FloydsToMint, "Not enough Floyds left on sale");
    //     _mintFloyd(msg.sender, nextFloydForSale, FloydToMint);
    //     cannotClaimAnymore(msg.sender);

    //     nextFloydForSale += FloydToMint;
    // }

    function buyFloyd(uint16 FloydsToBuy)
        public
        payable
        whenNotPaused
        {
            require(FloydsToBuy > 0, "Cannot buy 0 Floyds");
            require(leftForSale() >= FloydsToBuy, "Not enough Floyds left on sale");
            require(FloydsToBuy <= maxFloydToBuyAtOnce, "Cannot buy that many Floyds at once");
            require(msg.value >= singleFloydPrice * FloydsToBuy, "Insufficient funds sent.");
            _mintFloyd(msg.sender, nextFloydForSale, FloydsToBuy);

            nextFloydForSale += FloydsToBuy;
        }

    function leftForSale() public view returns(uint256) {
        return maxFloyd - nextFloydForSale;
    }

    function leftForGiveaway() public view returns(uint) {
        return sellableFloydStartingIndex - nextFloydToGiveaway;
    }

    function leftSpecial() public view returns(uint) {
        return giveawayFloydStartingIndex - nextSpecialFloyd;
    }

    function giveawayFloyd(address to) public onlyOwner {
        require(leftForGiveaway() >= 1);
        _mintFloyd(to, nextFloydToGiveaway++, 1);
    }

    function mintSpecialFloyd(address to) public onlyOwner {
        require(leftSpecial() >= 1);
        _mintFloyd(to, nextSpecialFloyd++, 1);
    }

    function startSale() public onlyOwner whenPaused {
        _unpause();
    }

    function pauseSale() public onlyOwner whenNotPaused {
        _pause();
    }
}

contract Floyd is Floydselling {
    string _provenanceHash;
    string baseURI_;
    address proxyRegistryAddress;

    //needs to be set to our API
    constructor(address _proxyRegistryAddress) ERC721("Floyd", "FLOYD") {
        proxyRegistryAddress = _proxyRegistryAddress;
        _pause();
        setBaseURI("https://api.Floyd.io/api/");
    }

    function contractURI() public pure returns (string memory) {
        return "https://api.Floyd.io/contract/opensea-Floyd";
    }

    /**
     * @dev Withdraws all contract funds and distributes across treasury wallets.
     * @dev Can only be called by owner.
     */
    function withdrawAll() public onlyOwner {
        for (uint256 i = 0; i < _treasuryWallets.length; i++) {
            address payable wallet = payable(_treasuryWallets[i]);
            release(wallet);
        }
    }

    function setProvenanceHash(string memory provenanceHash) public onlyOwner
    {
        _provenanceHash = provenanceHash;
    }

    function setBaseURI(string memory baseURI) public onlyOwner
    {
        baseURI_ = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI_;
    }

    function isApprovedOrOwner(address target, uint256 tokenId) public view returns (bool) {
        return _isApprovedOrOwner(target, tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function tokensInWallet(address wallet) public view returns (uint256[] memory) {
        uint256[] memory tokens = new uint256[](balanceOf(wallet));

        for (uint i = 0; i < tokens.length; i++) {
            tokens[i] = tokenOfOwnerByIndex(wallet, i);
        }

        return tokens;
    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Floyd: caller is not owner nor approved");
        _burn(tokenId);
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}
