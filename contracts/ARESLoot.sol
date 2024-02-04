// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/******************************************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░██████████░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░██████████░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░████████████████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░████████████████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░█████░░░░░██████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░█████░░░░░██████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *****************************************************/

contract ARESLoot is ERC721Enumerable, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;

    event Message(
        address owner,
        uint tokenId,
        address playerAddr,
        uint moreGold
    );

    bool public frozen;

    Counters.Counter private _tokenIdCounter;
    uint public goldSum;
    uint public glorySum;
    uint public feeSum;

    struct LootStorage {
        address burnerWalletAddress;
        string playerName;
        string teamName;
        bool canNotChange;
        uint gold;
        uint glory;
    }

    mapping(uint256 => LootStorage) public ARESLootStorage;
    mapping(address => uint256) public mintCount;
    mapping(address => uint256) public rank;

    modifier notFrozen() {
        require(!frozen, "already frozen");
        _;
    }

    modifier onlyEOA() {
        require(tx.origin == _msgSender(), "only EOA");
        _;
    }

    constructor() ERC721("ARESLoot v0.1.1", "ARES") Ownable() {
        frozen = true;
    }

    function freeze() public onlyOwner notFrozen {
        frozen = true;
    }

    function thaw() public onlyOwner {
        frozen = false;
    }

    function claimFund() public onlyOwner {
        uint balance = address(this).balance;
        Address.sendValue(payable(_msgSender()), balance);
    }

    function setRank(
        address[] calldata addrs,
        uint[] calldata ranks
    ) external onlyOwner {
        require(addrs.length == ranks.length, "length eq");
        for (uint i = 0; i < addrs.length; i++) {
            rank[addrs[i]] = ranks[i];
        }
    }

    function mint(
        address _burnerWalletAddress,
        string memory _playerName,
        string memory _teamName,
        uint _gold,
        uint _glory
    ) public payable nonReentrant notFrozen onlyEOA {
        require(_burnerWalletAddress != address(0), "invalid address");
        uint mintCnt = mintCount[_msgSender()];

        uint fee = mintCnt == 0 ? 0 : 2 ** (mintCnt - 1);
        uint amount = (fee + _gold + _glory) * 1 ether;
        require(msg.value == amount, "mint: eq");

        goldSum += _gold;
        glorySum += _glory;
        feeSum += fee;

        _tokenIdCounter.increment();
        uint tokenId = _tokenIdCounter.current();

        _safeMint(_msgSender(), tokenId);

        LootStorage storage lootStorage = ARESLootStorage[tokenId];
        lootStorage.burnerWalletAddress = _burnerWalletAddress;
        lootStorage.playerName = _playerName;
        lootStorage.teamName = _teamName;
        lootStorage.gold = _gold;
        lootStorage.glory = _glory;

        if (_gold > 0)
            emit Message(_msgSender(), tokenId, _burnerWalletAddress, _gold);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (!_exists(tokenId)) revert("invalid tokenId");
        LootStorage storage lootStorage = ARESLootStorage[tokenId];
        string[18] memory parts;

        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: #fee761; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="#3a4466" /><text x="10" y="20" class="base">';

        parts[1] = string(abi.encodePacked("DF ARES v0.1 Round 1"));

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = string(abi.encodePacked("Ticket # ", toString(tokenId)));

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = string(
            abi.encodePacked(toAsciiString(lootStorage.burnerWalletAddress))
        );

        parts[6] = '</text><text x="10" y="80" class="base">';

        if (
            keccak256(abi.encodePacked((lootStorage.playerName))) ==
            keccak256(abi.encodePacked(("")))
        ) parts[7] = string(abi.encodePacked("Anonymous Adventurer"));
        else parts[7] = string(abi.encodePacked(lootStorage.playerName));

        parts[8] = '</text><text x="10" y="100" class="base">';

        if (
            keccak256(abi.encodePacked(lootStorage.teamName)) ==
            keccak256(abi.encodePacked(("")))
        ) parts[9] = string(abi.encodePacked("DF ARES Community"));
        else
            parts[9] = string(abi.encodePacked("Team: ", lootStorage.teamName));

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = string(
            abi.encodePacked("Gold +", toString(lootStorage.gold))
        );

        parts[12] = '</text><text x="10" y="140" class="base">';

        parts[13] = string(
            abi.encodePacked("Glory +", toString(lootStorage.glory))
        );

        parts[14] = '</text><text x="10" y="160" class="base">';

        if (rank[lootStorage.burnerWalletAddress] == 0) {
            parts[15] = string(abi.encodePacked(""));
        } else
            parts[15] = string(
                abi.encodePacked(
                    "Rank # ",
                    toString(rank[lootStorage.burnerWalletAddress])
                )
            );

        parts[16] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[9],
                parts[10],
                parts[11],
                parts[12],
                parts[13],
                parts[14],
                parts[15],
                parts[16]
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Ticket #',
                        toString(tokenId),
                        '", "description": "ARESLoot v0.1.1 is adventurer gear generated for DFARES v0.1 Round 1 and stored on a chain. Stats, images and other features are intentionally omitted for others to interpret. You may use Loot in any way you wish.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );

        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function setPlayerName(
        uint tokenId,
        string memory _playerName
    ) public notFrozen onlyEOA {
        require(_exists(tokenId), "invalid tokenId");
        LootStorage storage lootStorage = ARESLootStorage[tokenId];

        require(
            ownerOf(tokenId) == _msgSender() || owner() == _msgSender(),
            "only Ticket Owner or Contract Owner"
        );

        if (owner() != _msgSender()) {
            require(
                lootStorage.canNotChange == false,
                "Ticket Owner Can Not Change Name"
            );
        } else {
            lootStorage.canNotChange = true;
        }

        lootStorage.playerName = _playerName;
    }

    function setTeamName(
        uint tokenId,
        string memory _teamName
    ) public notFrozen onlyEOA {
        require(_exists(tokenId), "invalid tokenId");
        LootStorage storage lootStorage = ARESLootStorage[tokenId];

        require(
            ownerOf(tokenId) == _msgSender() || owner() == _msgSender(),
            "only Ticket Owner or Contract Owner"
        );

        if (owner() != _msgSender()) {
            require(
                lootStorage.canNotChange == false,
                "Ticket Owner Can Not Change Name"
            );
        } else {
            lootStorage.canNotChange = true;
        }

        lootStorage.teamName = _teamName;
    }

    function more(
        uint tokenId,
        uint _moreGold,
        uint _moreGlory
    ) public payable nonReentrant notFrozen onlyEOA {
        require(_exists(tokenId), "invalid tokenId");
        LootStorage storage lootStorage = ARESLootStorage[tokenId];

        require(ownerOf(tokenId) == _msgSender(), "only ticket owner");
        uint amount = (_moreGold + _moreGlory) * 1 ether;
        require(amount > 0, "amount gt 0");
        require(msg.value == amount, "mint: eq");

        goldSum += _moreGold;
        glorySum += _moreGlory;

        lootStorage.gold += _moreGold;
        lootStorage.glory += _moreGlory;

        if (_moreGold > 0)
            emit Message(
                _msgSender(),
                tokenId,
                lootStorage.burnerWalletAddress,
                _moreGold
            );
    }

    // just some functions
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
