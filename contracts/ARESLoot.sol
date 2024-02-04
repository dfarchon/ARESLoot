// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/******************************************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░██████████░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░██████████░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░██████████░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░████████████████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░████████████████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░████████████████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░█████░░░░░██████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░█████░░░░░██████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░█████░░░░░██████████░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *****************************************************/

struct Player {
    bool isInitialized;
    address player;
    uint256 initTimestamp;
    uint256 homePlanetId;
    uint256 lastRevealTimestamp;
    uint256 score;
    uint256 spaceJunk;
    uint256 spaceJunkLimit;
    bool claimedShips;
    uint256 finalRank;
    bool claimedReward;
    uint256 activateArtifactAmount;
    uint256 buyArtifactAmount;
    uint256 silver;
    uint256 dropBombAmount;
    uint256 pinkAmount;
    uint256 pinkedAmount;
    uint256 moveCount;
    uint256 hatCount;
}

// DF ARES v0.1 Round 2
// Ticket # num
// [Adventurer|Contributor]: name | team name
// homePlanetId

// mainAccount
// burnerAccount
// rank => 0 | score => 0 | silver => 0 | move => 0
// acitvate x artifact(s) activateArtifactAmount => 0

// drop x bomb(s)    dropBombAmount => 0
// pink x planet(s)  pinkAmount => 0
// x planet(s) destroyed by others.  pinkedAmount => 0
// wear x hat(s)

// first Mythic Artifact Owner
// first BurnLocation Operator
// first hat buyer

interface IDFAres {
    function isWhitelisted(address _addr) external view returns (bool);

    function players(address key) external view returns (Player memory);

    function getScore(address player) external view returns (uint256);

    function getFirstMythicArtifactOwner() external view returns (address);

    function getFirstBurnLocationOperator() external view returns (address);

    function getFirstHat() external view returns (address);
}

contract ARESLoot is ERC721Enumerable, ReentrancyGuard, Ownable {
    modifier notFrozen() {
        require(!frozen, "already frozen");
        _;
    }

    modifier onlyEOA() {
        require(tx.origin == _msgSender(), "only EOA");
        _;
    }

    modifier exists(uint256 tokenId) {
        require(_ownerOf(tokenId) != address(0), "invalid tokenId");
        _;
    }

    IDFAres internal DFAresContract;

    // burnerAccount => mainAccount
    mapping(address => address) burnerToMain;

    // burnerAccount => Has it been minted already?
    mapping(address => bool) minted;

    // burnerAccount => role
    // 0 => adventurer
    // 1 => contributor
    mapping(address => uint) roles;

    uint private _tokenIdCounter; // Ticket 46 - x

    struct Metadata1 {
        uint role;
        string playerName;
        string teamName;
        uint homePlanetId;
        address mainAccount;
        address burnerAccount;
        uint rank;
        uint score;
        uint silver;
        uint move;
    }

    struct Metadata2 {
        uint activateArtifactAmount;
        uint dropBombAmount;
        uint pinkAmount;
        uint pinkedAmount;
        uint hatCount;
        bool ifFirstMythicArtifactOwner;
        bool ifFirstBurnLocationOperator;
        bool ifFirstHat;
    }

    mapping(uint256 => Metadata1) public metadataStorage1;
    mapping(uint256 => Metadata2) public metadataStorage2;
    bool public frozen;

    constructor(
        IDFAres _DFAresContract
    ) ERC721("ARESLoot v0.1.2", "ARES") Ownable(_msgSender()) {
        DFAresContract = _DFAresContract;
        frozen = true;
        _tokenIdCounter = 45; // first tokenId = 46
    }

    // admin
    function freeze() public onlyOwner notFrozen {
        frozen = true;
    }

    // Tip: submit ranklist to game contract before call thaw
    function thaw() public onlyOwner {
        frozen = false;
    }

    function claimFund() public onlyOwner {
        uint balance = address(this).balance;
        Address.sendValue(payable(_msgSender()), balance);
    }

    function batchAddRoles(
        address[] memory _burnerAccounts,
        uint[] memory _roles
    ) public onlyOwner {
        require(_burnerAccounts.length == _roles.length, "length");
        for (uint i = 0; i < _burnerAccounts.length; i++) {
            roles[_burnerAccounts[i]] = _roles[i];
        }
    }

    function adminChangeName(
        uint tokenId,
        string memory playerName,
        string memory teamName
    ) public notFrozen exists(tokenId) onlyEOA onlyOwner {
        Metadata1 storage metadata1 = metadataStorage1[tokenId];
        metadata1.playerName = playerName;
        metadata1.teamName = teamName;
    }

    // analysis

    function bulkGetMetadata1(
        uint256[] calldata ids
    ) public view returns (Metadata1[] memory ret) {
        ret = new Metadata1[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            ret[i] = metadataStorage1[ids[i]];
        }
    }

    function bulkGetMetadata2(
        uint256[] calldata ids
    ) public view returns (Metadata2[] memory ret) {
        ret = new Metadata2[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            ret[i] = metadataStorage2[ids[i]];
        }
    }

    // player
    function setMainAccount(address mainAccount) public {
        require(DFAresContract.isWhitelisted(_msgSender()), "not whitelisted");
        require(mainAccount != address(0), "not zero address");
        require(_msgSender() != mainAccount, "burnerAccount != mainAccount");
        burnerToMain[_msgSender()] = mainAccount;
    }

    function mint(
        address burnerAccount,
        string memory playerName,
        string memory teamName
    ) public nonReentrant notFrozen onlyEOA {
        require(DFAresContract.isWhitelisted(burnerAccount), "not whitelisted");
        require(
            burnerToMain[burnerAccount] == _msgSender(),
            "only main account"
        );

        require(len(playerName) <= 20, "player name too long");
        require(len(teamName) <= 40, "team name too long");
        require(minted[burnerAccount] == false, "minted");

        // Tip: need admin to upload ranklist first
        Player memory player = DFAresContract.players(burnerAccount);

        require(
            (roles[burnerAccount] == 0 && player.finalRank != 0) ||
                roles[burnerAccount] != 0,
            "only player and contributor"
        );

        uint tokenId = ++_tokenIdCounter;

        minted[burnerAccount] = true;

        Metadata1 storage metadata1 = metadataStorage1[tokenId];
        Metadata2 storage metadata2 = metadataStorage2[tokenId];
        metadata1.role = roles[burnerAccount];
        metadata1.playerName = playerName;
        metadata1.teamName = teamName;
        metadata1.homePlanetId = player.homePlanetId;
        metadata1.mainAccount = _msgSender();
        metadata1.burnerAccount = burnerAccount;
        metadata1.rank = player.finalRank;
        metadata1.score = DFAresContract.getScore(burnerAccount);
        metadata1.silver = player.silver;
        metadata1.move = player.moveCount;
        metadata2.activateArtifactAmount = player.activateArtifactAmount;
        metadata2.dropBombAmount = player.dropBombAmount;
        metadata2.pinkAmount = player.pinkAmount;
        metadata2.pinkedAmount = player.pinkedAmount;
        metadata2.hatCount = player.hatCount;
        metadata2.ifFirstMythicArtifactOwner =
            DFAresContract.getFirstMythicArtifactOwner() == burnerAccount;
        metadata2.ifFirstBurnLocationOperator =
            DFAresContract.getFirstBurnLocationOperator() == burnerAccount;
        metadata2.ifFirstHat = DFAresContract.getFirstHat() == burnerAccount;
        _safeMint(_msgSender(), tokenId);
    }

    function hardRefreshMetadata(
        uint256 tokenId
    ) public nonReentrant notFrozen exists(tokenId) onlyEOA {
        Metadata1 storage metadata1 = metadataStorage1[tokenId];
        Metadata2 storage metadata2 = metadataStorage2[tokenId];
        address burnerAccount = metadata1.burnerAccount;

        Player memory player = DFAresContract.players(burnerAccount);
        metadata1.role = roles[burnerAccount];

        metadata1.homePlanetId = player.homePlanetId;
        metadata1.mainAccount = _msgSender();
        metadata1.burnerAccount = burnerAccount;
        metadata1.rank = player.finalRank;
        metadata1.score = DFAresContract.getScore(burnerAccount);
        metadata1.silver = player.silver;
        metadata1.move = player.moveCount;
        metadata2.activateArtifactAmount = player.activateArtifactAmount;
        metadata2.dropBombAmount = player.dropBombAmount;
        metadata2.pinkAmount = player.pinkAmount;
        metadata2.pinkedAmount = player.pinkedAmount;
        metadata2.hatCount = player.hatCount;
        metadata2.ifFirstMythicArtifactOwner =
            DFAresContract.getFirstMythicArtifactOwner() == burnerAccount;
        metadata2.ifFirstBurnLocationOperator =
            DFAresContract.getFirstBurnLocationOperator() == burnerAccount;
        metadata2.ifFirstHat = DFAresContract.getFirstHat() == burnerAccount;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override exists(tokenId) returns (string memory) {
        Metadata1 storage metadata1 = metadataStorage1[tokenId];
        Metadata2 storage metadata2 = metadataStorage2[tokenId];
        string[30] memory parts;

        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: #004c3f; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="#ffb4c1" /><text x="10" y="20" class="base">';

        parts[1] = string(abi.encodePacked("DF ARES v0.1 Round 2"));
        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = string(abi.encodePacked("Ticket # ", toString(tokenId)));
        parts[4] = '</text><text x="10" y="60" class="base">';

        if (
            keccak256(abi.encodePacked((metadata1.playerName))) ==
            keccak256(abi.encodePacked(("")))
        ) {
            if (metadata1.role == 0)
                parts[5] = string(abi.encodePacked("Anonymous Adventurer"));
            else parts[5] = string(abi.encodePacked("Anonymous Contributor"));
        } else {
            if (metadata1.role == 0)
                parts[5] = string(abi.encodePacked("Adventurer: "));
            else parts[5] = string(abi.encodePacked("Contributor: "));

            parts[5] = string(abi.encodePacked(parts[5], metadata1.playerName));
        }

        parts[6] = '</text><text x="10" y="80" class="base">';

        if (
            keccak256(abi.encodePacked((metadata1.teamName))) !=
            keccak256(abi.encodePacked(("")))
        ) {
            parts[7] = string(abi.encodePacked(metadata1.teamName));
        } else parts[7] = string(abi.encodePacked("Dark Forest Community"));

        parts[8] = '</text><text x="10" y="100" class="base">';
        parts[9] = string(
            abi.encodePacked(
                "Main",
                unicode"🌍",
                " ",
                toAsciiString(metadata1.mainAccount)
            )
        );

        parts[10] = '</text><text x="10" y="120" class="base">';
        parts[11] = string(
            abi.encodePacked(
                "Burner",
                unicode"🪐",
                " ",
                toAsciiString(metadata1.burnerAccount)
            )
        );

        parts[12] = '</text><text x="10" y="140" class="base">';

        if (metadata1.rank != 0)
            parts[13] = string(
                abi.encodePacked("Rank: ", toString(metadata1.rank))
            );
        else parts[13] = string(abi.encodePacked("Rank: ", unicode"∞"));

        if (
            metadata1.score !=
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        ) {
            parts[13] = string(
                abi.encodePacked(
                    parts[13],
                    " | Score: ",
                    toString(metadata1.score)
                )
            );
        } else {
            parts[13] = string(
                abi.encodePacked(parts[13], " | Score: ", unicode"∞")
            );
        }

        parts[14] = '</text><text x="10" y="160" class="base">';
        parts[15] = string(
            abi.encodePacked(parts[15], "Silver: ", toString(metadata1.silver))
        );
        parts[15] = string(
            abi.encodePacked(parts[15], " | Move: ", toString(metadata1.move))
        );

        parts[16] = '</text><text x="10" y="180" class="base">';
        parts[17] = string(
            abi.encodePacked(
                "Acitvate ",
                toString(metadata2.activateArtifactAmount),
                " artifact"
            )
        );

        if (metadata2.activateArtifactAmount > 1) {
            parts[17] = string(abi.encodePacked(parts[17], "s"));
        }

        parts[18] = '</text><text x="10" y="200" class="base">';
        parts[19] = string(
            abi.encodePacked(
                "Drop ",
                toString(metadata2.dropBombAmount),
                " bomb"
            )
        );

        if (metadata2.dropBombAmount > 1) {
            parts[19] = string(abi.encodePacked(parts[19], "s"));
        }

        parts[20] = '</text><text x="10" y="220" class="base">';
        parts[21] = string(
            abi.encodePacked("Pink ", toString(metadata2.pinkAmount), " planet")
        );

        if (metadata2.pinkAmount > 1) {
            parts[21] = string(abi.encodePacked(parts[21], "s"));
        }

        parts[22] = '</text><text x="10" y="240" class="base">';
        if (metadata2.pinkedAmount < 2) {
            parts[23] = string(
                abi.encodePacked(
                    toString(metadata2.pinkedAmount),
                    " planet destroyed by others"
                )
            );
        } else {
            parts[23] = string(
                abi.encodePacked(
                    toString(metadata2.pinkedAmount),
                    " planets destroyed by others"
                )
            );
        }

        parts[24] = '</text><text x="10" y="260" class="base">';

        parts[25] = string(
            abi.encodePacked("Wear ", toString(metadata2.hatCount), " hat")
        );

        if (metadata2.hatCount > 1) {
            parts[25] = string(abi.encodePacked(parts[25], "s"));
        }

        parts[26] = '</text><text x="10" y="280" class="base">';

        if (metadata2.ifFirstBurnLocationOperator) {
            parts[27] = string(abi.encodePacked(unicode"😈"));
        } else if (metadata2.ifFirstBurnLocationOperator) {
            parts[27] = string(abi.encodePacked(unicode"💣"));
        } else if (metadata2.ifFirstHat) {
            parts[27] = string(abi.encodePacked(unicode"🎩"));
        }

        parts[28] = "</text></svg>";

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
                parts[8],
                parts[9],
                parts[10],
                parts[11],
                parts[12],
                parts[13],
                parts[14],
                parts[15],
                parts[16],
                parts[17],
                parts[18],
                parts[19],
                parts[20],
                parts[21],
                parts[22],
                parts[23],
                parts[24],
                parts[25],
                parts[26],
                parts[27],
                parts[28]
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Ticket #',
                        toString(tokenId),
                        '", "description": "ARES Loot is the ticket to enter new world. ", "image": "data:image/svg+xml;base64,',
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

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp > 0) {
            temp /= 16;
            length++;
        }
        bytes memory result = new bytes(length);
        for (uint256 i = length; i > 0; i--) {
            result[i - 1] = toHexChar(value % 16);
            value /= 16;
        }
        return string(result);
    }

    function toHexChar(uint256 value) internal pure returns (bytes1) {
        if (value < 10) {
            return bytes1(uint8(value + 48));
        } else {
            return bytes1(uint8(value + 87));
        }
    }

    function len(string memory s) public pure returns (uint256) {
        return bytes(s).length;
    }
}
