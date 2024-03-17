// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {IERC1924} from "./IERC1924.sol";
import {LibString} from "solmate/utils/LibString.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

/// @title   ERC1924 - Harberger Standard Proposal
/// @author  0xlpd
/// @author  timmbonodiaz
/// @notice  Proposal for a standard implementation of a harberger tax enabled non-fungible token collection.
/// @dev     Supports ERC-721 interface, including metadata, but reverts on all transfers and approvals.

contract ERC1924 is ERC721, IERC1924, Owned(msg.sender), ReentrancyGuard {
    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    event Mint(address indexed patron, uint256 tokenId, uint256 valuation, uint256 amount);
    event Deposit(address indexed patron, uint256 amount);
    event ValuationUpdate(uint256 tokenId, uint256 newValuation);
    event Withdraw(address indexed patron, uint256 amount);
    event MinPeriodCoveredUpdate(uint256 newMinPeriodCovered);
    event TaxNumeratorUpdate(uint256 newTaxNumerator);

    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    error ZeroAddress();
    error NotAuthorized();
    error NonTransferable();
    error MaxSupply();
    error InsufficientDeposit();
    error NotPatron();
    error NoTokensOwned();
    error NotDefaulted();
    error NonExistentToken();
    error LowValuation();
    error InsufficientFunds();
    error IncorrectFee();

    uint256 public totalSupply;
    uint256 public immutable maxSupply;
    string public baseURI;

    mapping(address => uint256) public deposits;
    mapping(uint256 => uint256) public valuations;
    mapping(address => uint256) public lastCollections;
    mapping(address => uint256) public totalCosts;

    uint256 public taxNumerator;
    uint256 public constant TAX_DENOMINATOR = 10_000;
    uint256 public immutable taxPeriod;
    uint256 public minPeriodCovered;

    uint256 public constant SHARE_DENOMINATOR = 10_000;
    uint256 public previousHolderShare;
    uint256 public benefactorShare;

    address public benefactor;
    uint256 public benefactorBalance;

    /// @param _name Name for the collection
    /// @param _symbol Symbol for the collection
    /// @param _baseURI Base URI for the collection
    /// @param _maxSupply Max amount of tokens that can be minted
    /// @param _taxPeriod Time over which the tax will be charged
    /// @param _minPeriodCovered Minimum time period that the deposit has to cover
    /// @param _previousHolderShare Share of the purchasing price that goes to the previous holder
    /// @param _benefactor Address to pay the taxes
    /// @param _benefactorShare Share of the purchasing price that goes to the benefactor
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _maxSupply,
        uint256 _taxPeriod,
        uint256 _taxNumerator,
        uint256 _minPeriodCovered,
        uint256 _previousHolderShare,
        address _benefactor,
        uint256 _benefactorShare
    ) ERC721(_name, _symbol) {
        baseURI = _baseURI;
        maxSupply = _maxSupply;
        taxPeriod = _taxPeriod;
        taxNumerator = _taxNumerator;
        minPeriodCovered = _minPeriodCovered;
        previousHolderShare = _previousHolderShare;
        benefactor = _benefactor;
        benefactorShare = _benefactorShare;
    }

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyPatron(uint256 tokenId) {
        if (msg.sender != _ownerOf[tokenId]) revert NotPatron();
        _;
    }

    modifier collect(address patron) {
        collectTax(patron);
        _;
    }

    modifier onlyAdminOrBenefactor() {
        if (msg.sender != benefactor || msg.sender != owner) revert NotAuthorized();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                        CORE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Initial mint for the collection tokens
    /// @param valuation The valuation assigned to the new token
    /// @dev The valuation needs to be higher than the one stablished by the previous holder.
    function mint(uint256 valuation) external payable nonReentrant returns (uint256) {
        if (totalSupply >= maxSupply) revert MaxSupply();

        uint256 minValue = valuation * minPeriodCovered * taxNumerator / TAX_DENOMINATOR / taxPeriod;
        if (msg.value < minValue) revert InsufficientDeposit();

        uint256 tokenId = ++totalSupply;

        deposits[msg.sender] += msg.value;
        lastCollections[msg.sender] = block.timestamp;
        valuations[tokenId] = valuation;
        totalCosts[msg.sender] += valuation * taxNumerator;

        _mint(msg.sender, tokenId);
        emit Mint(msg.sender, tokenId, valuation, msg.value);

        return tokenId;
    }

    /// @notice Collects the tax owed by a patron
    /// @param patron The address of the patron to collect tax from
    /// @dev If the patron has defaulted on its debt, their assets become available to be foreclosed
    function collectTax(address patron) public {
        uint256 patronageOwed = owedBy(patron);
        uint256 patronDeposit = deposits[patron];

        if (patronageOwed < patronDeposit) {
            lastCollections[patron] = block.timestamp;
            benefactorBalance += patronageOwed;
            deposits[patron] -= patronageOwed;
        } else {
            uint256 lastCollection = lastCollections[patron];
            uint256 timeSinceLastCollection = block.timestamp - lastCollection;
            uint256 exactForeclosureTime = lastCollection + (timeSinceLastCollection * patronDeposit) / patronageOwed;
            lastCollections[patron] = exactForeclosureTime;
            benefactorBalance += patronDeposit;
            deposits[patron] = 0;
        }
    }

    /// @notice Forecloses a tokenId that has defaulted on its debt. Returns it to the contract
    /// @param tokenId Token to foreclose
    function foreclose(uint256 tokenId) external collect(_ownerOf[tokenId]) {
        address patron = _ownerOf[tokenId];
        uint256 taxesDue = owedBy(patron);
        if (taxesDue <= deposits[patron]) revert NotDefaulted();

        totalCosts[patron] -= valuations[tokenId] * taxNumerator;
        unchecked {
            _ownerOf[tokenId] = address(this);
            _balanceOf[patron]--;
            _balanceOf[address(this)]++;
            valuations[tokenId] = 0;
        }
    }

    /// @notice Lets a patron return a token
    /// @param tokenId The token to return
    function refundToken(uint256 tokenId) external nonReentrant onlyPatron(tokenId) collect(msg.sender) {
        totalCosts[msg.sender] -= valuations[tokenId] * taxNumerator;
        unchecked {
            _ownerOf[tokenId] = address(this);
            _balanceOf[msg.sender]--;
            _balanceOf[address(this)]++;
            valuations[tokenId] = 0;
        }
    }

    /// @notice Acquires a token from another patron.
    /// @param tokenId The token to acquire
    /// @param valuation The new valuation. Needs to be higher than the current valuation.
    function acquire(uint256 tokenId, uint256 valuation) external payable {
        if (tokenId > totalSupply || tokenId == 0) revert NonExistentToken();
        if (valuations[tokenId] >= valuation) revert LowValuation();

        address currentOwner = ownerOf(tokenId);
        uint256 minDeposit = valuation * minPeriodCovered / taxPeriod;
        uint256 benefactorPriceShare = valuation * benefactorShare / SHARE_DENOMINATOR;
        uint256 previousHolderPriceShare;
        if (currentOwner == address(this)) {
            previousHolderPriceShare = 0;
        } else {
            previousHolderPriceShare = valuation * previousHolderShare / SHARE_DENOMINATOR;
        }

        if (msg.value < (minDeposit + benefactorPriceShare + previousHolderPriceShare)) {
            revert InsufficientDeposit();
        }

        deposits[currentOwner] += previousHolderPriceShare;
        deposits[msg.sender] += msg.value - benefactorPriceShare - previousHolderPriceShare;
        totalCosts[msg.sender] += valuation * taxNumerator;

        if (currentOwner != address(this)) {
            collectTax(currentOwner);
            totalCosts[currentOwner] -= valuations[tokenId] * taxNumerator;
        }

        _ownerOf[tokenId] = msg.sender;
        _balanceOf[currentOwner]--;
        _balanceOf[msg.sender]++;

        valuations[tokenId] = valuation;
    }

    /// @notice Lets a patron update their valuation for a token
    /// @param tokenId The token to update valuation
    /// @param newValuation The new valuation
    function updateValuation(uint256 tokenId, uint256 newValuation)
        external
        payable
        nonReentrant
        onlyPatron(tokenId)
    {
        uint256 oldValuation = valuations[tokenId];
        valuations[tokenId] = newValuation;

        if (msg.value > 0) {
            deposits[msg.sender] += msg.value;
            emit Deposit(msg.sender, msg.value);
        }

        collectTax(msg.sender);

        totalCosts[msg.sender] = totalCosts[msg.sender] - (oldValuation * taxNumerator) + (newValuation * taxNumerator);

        emit ValuationUpdate(tokenId, newValuation);
    }

    /// @notice Lets someone deposit funds for a specific recipient
    /// @param recipient The target to receive funds
    function deposit(address recipient) external payable nonReentrant {
        if (recipient == address(0)) { revert ZeroAddress(); }

        deposits[recipient] += msg.value;
        emit Deposit(recipient, msg.value);
    }

    /// @notice Lets a user withdraw all their deposited funds
    function withdraw() external nonReentrant collect(msg.sender) returns (bool success) {
        uint256 patronDeposit = deposits[msg.sender];
        deposits[msg.sender] = 0;

        // slither-disable-next-line low-level-calls
        (success,) = msg.sender.call{value: patronDeposit}("");
        emit Withdraw(msg.sender, patronDeposit);
        return success;
    }

    /// @notice Lets a user withdraw a share of their deposited funds
    function withdraw(uint256 amount) external nonReentrant collect(msg.sender) returns (bool success) {
        uint256 patronDeposit = deposits[msg.sender];
        if (amount > patronDeposit) revert InsufficientFunds();

        deposits[msg.sender] -= amount;

        // slither-disable-next-line low-level-calls
        (success,) = msg.sender.call{value: amount}("");
        emit Withdraw(msg.sender, amount);
        return success;
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Checks if a given token is in default
    /// @param tokenId The token to check for debt
    function foreclosed(uint256 tokenId) external view returns (bool) {
        return foreclosedPatron(_ownerOf[tokenId]);
    }

    /// @notice Checks if a patron has defaulted on its debt
    /// @param patron Address of the patron to check for debt
    function foreclosedPatron(address patron) public view returns (bool) {
        return owedBy(patron) >= deposits[patron];
    }

    /// @notice Checks for remaining deposit for a patron
    /// @param patron The address of the patron to check
    function getRemainingDeposit(address patron) public view returns (uint256) {
        uint256 taxesDue = owedBy(patron);
        if (taxesDue >= deposits[patron]) {
            return 0;
        } else {
            return deposits[patron] - taxesDue;
        }
    }

    /// @notice Returns the timestamp when a specific token will default
    /// @param tokenId The token to check
    function foreclosureTime(uint256 tokenId) external view returns (uint256) {
        if (tokenId > totalSupply || tokenId == 0) revert NonExistentToken();

        address patron = _ownerOf[tokenId];
        return foreclosureTimePatron(patron);
    }

    /// @notice Returns the timestamp when a patron will default on its debts
    /// @param patron The address of the patron to check
    function foreclosureTimePatron(address patron) public view returns (uint256) {
        uint256 taxPerSecond = totalCosts[patron] / taxPeriod / TAX_DENOMINATOR;
        if(taxPerSecond == 0) return type(uint256).max;

        return block.timestamp + getRemainingDeposit(patron) / taxPerSecond;
    }

    /// @notice Returns the debt owed by patron.
    /// @param patron Address to check debt
    function owedBy(address patron) public view returns (uint256 patronageDue) {
        return totalCosts[patron] * (block.timestamp - lastCollections[patron]) / taxPeriod / TAX_DENOMINATOR;
    }

    /// @notice Get metadata URI for a given token
    /// @return URI unique uri for the token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (tokenId > totalSupply || tokenId == 0 || bytes(baseURI).length == 0) {
            revert NonExistentToken();
        }
        return string.concat(baseURI, LibString.toString(tokenId));
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Allows the owner to update the minimum period that has to be covered by a deposit to acquire a token.
    /// @param newMinPeriodCovered Minimum time required
    function setMinPeriodCovered(uint256 newMinPeriodCovered) external onlyOwner {
        minPeriodCovered = newMinPeriodCovered;
        emit MinPeriodCoveredUpdate(newMinPeriodCovered);
    }

    /// @notice Allows the owner to update the tax charged for tax period.
    /// @param newTaxNumerator Nmber to use as numerator when calculating tax per period.
    function setTaxNumerator(uint256 newTaxNumerator) external onlyOwner {
        taxNumerator = newTaxNumerator;
        emit TaxNumeratorUpdate(newTaxNumerator);
    }

    /// @notice Allows either the admin or benefactor to update the recipient address.
    /// @param _benefactor The new address to use as benefactor
    function setBenefactor(address _benefactor) external onlyAdminOrBenefactor {
        if (_benefactor == address(0)) { revert ZeroAddress(); }

        benefactor = _benefactor;
    }

    /// @notice Allows the owner to update the royalty the benefactor gets on each acquisition
    /// @param newBenefactorShare The new fee to give the benefactor
    /// @dev This fee + the previous holder fee shouldn't add up to more than 10000.
    function setBenefactorShare(uint256 newBenefactorShare) external onlyOwner {
        if (newBenefactorShare > SHARE_DENOMINATOR - previousHolderShare) revert IncorrectFee();

        benefactorShare = newBenefactorShare;
    }

    /// @notice Allows the owner to update the fee that goes to the previous holder on each acquisition
    /// @param newPreviousHolderShare The new fee to give the previous holder
    /// @dev This fee + the benefactor fee shouldn't add up to more than 10000.
    function setPreviousHolderShare(uint256 newPreviousHolderShare) external onlyOwner {
        if (newPreviousHolderShare > SHARE_DENOMINATOR - benefactorShare) revert IncorrectFee();

        previousHolderShare = newPreviousHolderShare;
    }


    /// @notice Set the base URI for the token
    /// @param uri New base URI
    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    /// @notice Withdraw funds from the contract
    /// @return success Whether the transfer was successful
    function withdrawBenefactor() external returns (bool success) {
        uint256 balance = benefactorBalance;
        benefactorBalance = 0;

        // slither-disable-next-line low-level-calls
        (success,) = benefactor.call{value: balance}("");
        return success;
    }

    /*//////////////////////////////////////////////////////////////
                        DISABLE ERC721 TRANSFERS
    //////////////////////////////////////////////////////////////*/

    function transferFrom(address, address, uint256) public pure override {
        revert NonTransferable();
    }

    function safeTransferFrom(address, address, uint256) public pure override {
        revert NonTransferable();
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) public pure override {
        revert NonTransferable();
    }

    /*//////////////////////////////////////////////////////////////
                        FALLBACK FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @dev Handles direct ETH transfers as deposits.
    receive() external payable nonReentrant {
        deposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
