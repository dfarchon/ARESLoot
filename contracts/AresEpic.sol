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

// Player struct for Round 4
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
    uint256 kardashevAmount;
    uint256 buyPlanetAmount;
    uint256 buySpaceshipAmount;
    uint256 donationAmount; // amount (ether) * CONTRACT_PERCISION
    uint256 unionId;
    uint256 leaveUnionTimestamp;
}

struct PlayerLog {
    uint256 buySkinCnt;
    uint256 buySkinCost;
    uint256 takeOffSkinCnt;
    uint256 withdrawSilverCnt;
    uint256 claimLocationCnt;
    uint256 changeArtifactImageTypeCnt;
    uint256 deactivateArtifactCnt;
    uint256 prospectPlanetCnt;
    uint256 findArtifactCnt;
    uint256 depositArtifactCnt;
    uint256 withdrawArtifactCnt;
    uint256 kardashevCnt;
    uint256 blueLocationCnt;
    uint256 createLobbyCnt;
    uint256 moveCnt;
    uint256 burnLocationCnt;
    uint256 pinkLocationCnt;
    uint256 buyPlanetCnt;
    uint256 buyPlanetCost;
    uint256 buySpaceshipCnt;
    uint256 buySpaceshipCost;
    uint256 donateCnt;
    uint256 donateSum;
}

struct Union {
    uint256 unionId;
    string name;
    address leader;
    uint256 level;
    address[] members;
    address[] invitees;
    address[] applicants;
}

interface IDFAres {
    function isWhitelisted(address _addr) external view returns (bool);

    function players(address key) external view returns (Player memory);

    function unions(uint256 key) external view returns(Union memory);

    function getPlayerLog(
        address addr
    ) external view returns (PlayerLog memory);

    function getScore(address player) external view returns (uint256);

    function getFirstMythicArtifactOwner() external view returns (address);

    function getFirstBurnLocationOperator() external view returns (address);

    function getFirstKardashevOperator() external view returns (address);
}

// DF ARES v0.1 Round 4
// Ticket # num
// [Adventurer|Contributor]: name |
// union name
// mainAccount
// burnerAccount
// rank => 0 | score => 0 | silver => 0 | move => 0

// find x artifact(s) findArtifactCnt => 0
// acitvate x artifact(s) activateArtifactAmount => 0

// drop x bomb(s)    dropBombAmount => 0
// pink x planet(s)  pinkAmount => 0
// x planet(s) destroyed by others.  pinkedAmount => 0

// first Mythic Artifact Owner
// first BurnLocation Operator
// first hat buyer
// first kardashev Operator

contract AresEpic is ERC721Enumerable, ReentrancyGuard, Ownable {
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

    // burnerAccount => minted state
    // minted == 0, not minted
    // minted !=0, minted = tokenId
    mapping(address => uint) minted;

    // burnerAccount => role
    // 0 => adventurer
    // 1 => contributor
    mapping(address => uint) roles;

    uint private _tokenIdCounter; // Ticket 121 - x

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
        uint findArtifactAmount;
        uint activateArtifactAmount;
        uint dropBombAmount;
        uint pinkAmount;
        uint pinkedAmount;
        bool ifFirstMythicArtifactOwner;
        bool ifFirstBurnLocationOperator;
        bool ifFirstKardashevOperator;
    }

    mapping(uint256 => Metadata1) public metadataStorage1;
    mapping(uint256 => Metadata2) public metadataStorage2;
    bool public frozen;

    constructor(
        IDFAres _DFAresContract
    ) ERC721("Ares Epic v0.1.4", "ARES") Ownable(_msgSender()) {
        DFAresContract = _DFAresContract;
        frozen = true;
        _tokenIdCounter = 120; // first tokenId = 121
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

    function adminChangeMainAccount(
        uint tokenId,
        address _mainAccount
    ) public notFrozen exists(tokenId) onlyEOA onlyOwner {
        Metadata1 storage metadata1 = metadataStorage1[tokenId];
        metadata1.mainAccount = _mainAccount;
    }

    // analysis

    function getBurnerToMain(
        address burnerAccount
    ) public view returns (address) {
        return burnerToMain[burnerAccount];
    }

    function getMinted(address burnerAccount) public view returns (uint) {
        return minted[burnerAccount];
    }

    function getMetadata1(
        uint256 id
    ) public view returns (Metadata1 memory ret) {
        return metadataStorage1[id];
    }

    function getMetadata2(
        uint256 id
    ) public view returns (Metadata2 memory ret) {
        return metadataStorage2[id];
    }

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
    function mint(
        address mainAccount,
        string memory playerName
    ) public nonReentrant notFrozen onlyEOA {
        address burnerAccount = _msgSender();

        require(DFAresContract.isWhitelisted(burnerAccount), "not whitelisted");
        require(mainAccount != address(0), "not zero address");
        require(burnerAccount != mainAccount, "burnerAccount != mainAccount");

        require(len(playerName) <= 20, "player name too long");
        // require(len(teamName) <= 40, "team name too long");
        require(minted[burnerAccount] == 0, "minted");

        // Tip: need admin to upload ranklist first
        Player memory player = DFAresContract.players(burnerAccount);
        PlayerLog memory playerLog = DFAresContract.getPlayerLog(burnerAccount);
        Union memory union = DFAresContract.unions(player.unionId);

        require(
            (roles[burnerAccount] == 0 && player.finalRank != 0) ||
                roles[burnerAccount] != 0,
            "only player and contributor"
        );

        uint tokenId = ++_tokenIdCounter;

        burnerToMain[burnerAccount] = mainAccount;
        minted[burnerAccount] = tokenId;

        Metadata1 storage metadata1 = metadataStorage1[tokenId];
        Metadata2 storage metadata2 = metadataStorage2[tokenId];
        metadata1.role = roles[burnerAccount];
        metadata1.playerName = playerName;
        metadata1.teamName = union.name;
        metadata1.homePlanetId = player.homePlanetId;
        metadata1.mainAccount = mainAccount;
        metadata1.burnerAccount = burnerAccount;
        metadata1.rank = player.finalRank;
        metadata1.score = DFAresContract.getScore(burnerAccount);
        metadata1.silver = player.silver;
        metadata1.move = player.moveCount;

        metadata2.findArtifactAmount = playerLog.findArtifactCnt;
        metadata2.activateArtifactAmount = player.activateArtifactAmount;
        metadata2.dropBombAmount = player.dropBombAmount;
        metadata2.pinkAmount = player.pinkAmount;
        metadata2.pinkedAmount = player.pinkedAmount;
        metadata2.ifFirstMythicArtifactOwner =
            DFAresContract.getFirstMythicArtifactOwner() == burnerAccount;
        metadata2.ifFirstBurnLocationOperator =
            DFAresContract.getFirstBurnLocationOperator() == burnerAccount;
        metadata2.ifFirstKardashevOperator =
            DFAresContract.getFirstKardashevOperator() == burnerAccount;

        _safeMint(_msgSender(), tokenId);
    }

    function hardRefreshMetadata(
        uint256 tokenId
    ) public nonReentrant notFrozen exists(tokenId) onlyEOA {
        Metadata1 storage metadata1 = metadataStorage1[tokenId];
        Metadata2 storage metadata2 = metadataStorage2[tokenId];
        address burnerAccount = metadata1.burnerAccount;
        Player memory player = DFAresContract.players(burnerAccount);
        PlayerLog memory playerLog = DFAresContract.getPlayerLog(burnerAccount);
        Union memory union = DFAresContract.unions(player.unionId);

        metadata1.role = roles[burnerAccount];
        // metadata1.playerName = playerName;
        metadata1.teamName = union.name;
        metadata1.homePlanetId = player.homePlanetId;
        // metadata1.mainAccount = mainAccount;
        metadata1.burnerAccount = burnerAccount;
        metadata1.rank = player.finalRank;
        metadata1.score = DFAresContract.getScore(burnerAccount);
        metadata1.silver = player.silver;
        metadata1.move = player.moveCount;

        metadata2.findArtifactAmount = playerLog.findArtifactCnt;
        metadata2.activateArtifactAmount = player.activateArtifactAmount;
        metadata2.dropBombAmount = player.dropBombAmount;
        metadata2.pinkAmount = player.pinkAmount;
        metadata2.pinkedAmount = player.pinkedAmount;
        metadata2.ifFirstMythicArtifactOwner =
            DFAresContract.getFirstMythicArtifactOwner() == burnerAccount;
        metadata2.ifFirstBurnLocationOperator =
            DFAresContract.getFirstBurnLocationOperator() == burnerAccount;
        metadata2.ifFirstKardashevOperator =
            DFAresContract.getFirstKardashevOperator() == burnerAccount;
    }

    function batchHardRefreshMetadata(uint256[] memory tokenIds) public {
        for (uint i = 0; i < tokenIds.length; i++) {
            hardRefreshMetadata(tokenIds[i]);
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view override exists(tokenId) returns (string memory) {
        Metadata1 storage metadata1 = metadataStorage1[tokenId];
        Metadata2 storage metadata2 = metadataStorage2[tokenId];
        string memory cache;
        string memory output;

        //part[0]
        cache = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: #004c3f; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="#ffb4c1" /><text x="10" y="20" class="base">';
        output = string(abi.encodePacked(output, cache));

        //parts[1]
        cache = string(abi.encodePacked("Dark Forest Ares v0.1 Round 4"));
        output = string(abi.encodePacked(output, cache));

        //parts[2]
        cache = '</text><text x="10" y="40" class="base">';
        output = string(abi.encodePacked(output, cache));

        //parts[3]
        cache = string(abi.encodePacked("Ticket # ", toString(tokenId)));
        output = string(abi.encodePacked(output, cache));

        //parts[4]
        cache = '</text><text x="10" y="60" class="base">';
        output = string(abi.encodePacked(output, cache));

        //parts[5]
        if (
            keccak256(abi.encodePacked((metadata1.playerName))) ==
            keccak256(abi.encodePacked(("")))
        ) {
            if (metadata1.role == 0)
                cache = string(abi.encodePacked("Anonymous Adventurer"));
            else cache = string(abi.encodePacked("Anonymous Contributor"));
        } else {
            if (metadata1.role == 0)
                cache = string(abi.encodePacked("Adventurer: "));
            else cache = string(abi.encodePacked("Contributor: "));

            cache = string(abi.encodePacked(cache, metadata1.playerName));
        }
        output = string(abi.encodePacked(output, cache));

        // parts[6]
        cache = '</text><text x="10" y="80" class="base">';
        output = string(abi.encodePacked(output, cache));

        // parts[7]
        if (
            keccak256(abi.encodePacked((metadata1.teamName))) !=
            keccak256(abi.encodePacked(("")))
        ) {
            cache = string(abi.encodePacked(metadata1.teamName));
        } else cache = string(abi.encodePacked("Dark Forest Community"));
        output = string(abi.encodePacked(output, cache));

        // parts[8]
        cache = '</text><text x="10" y="100" class="base">';
        output = string(abi.encodePacked(output, cache));

        // parts[9]
        cache = string(
            abi.encodePacked(
                "Main",
                unicode"🌍",
                " ",
                toAsciiString(metadata1.mainAccount)
            )
        );
        output = string(abi.encodePacked(output, cache));

        //parts[10]
        cache = '</text><text x="10" y="120" class="base">';
        output = string(abi.encodePacked(output, cache));

        //parts[11]
        cache = string(
            abi.encodePacked(
                "Burner",
                unicode"🪐",
                " ",
                toAsciiString(metadata1.burnerAccount)
            )
        );
        output = string(abi.encodePacked(output, cache));

        //parts[12]
        cache = '</text><text x="10" y="140" class="base">';
        output = string(abi.encodePacked(output, cache));

        //parts[13]
        if (metadata1.rank != 0)
            cache = string(
                abi.encodePacked("Rank: ", toString(metadata1.rank))
            );
        else cache = string(abi.encodePacked("Rank: ", unicode"∞"));

        if (
            metadata1.score !=
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        ) {
            cache = string(
                abi.encodePacked(cache, " | Score: ", toString(metadata1.score))
            );
        } else {
            cache = string(abi.encodePacked(cache, " | Score: ", unicode"∞"));
        }
        output = string(abi.encodePacked(output, cache));

        //parts[14]
        cache = '</text><text x="10" y="160" class="base">';
        output = string(abi.encodePacked(output, cache));

        // parts[15]
        cache = string(
            abi.encodePacked(cache, "Silver: ", toString(metadata1.silver))
        );

        cache = string(
            abi.encodePacked(cache, " | Move: ", toString(metadata1.move))
        );

        output = string(abi.encodePacked(output, cache));

        //parts[16]
        cache = '</text><text x="10" y="180" class="base">';
        output = string(abi.encodePacked(output, cache));

        //parts[17]
        cache = string(
            abi.encodePacked(
                "Find ",
                toString(metadata2.findArtifactAmount),
                " artifact"
            )
        );
        if (metadata2.findArtifactAmount > 1) {
            cache = string(abi.encodePacked(cache, "s"));
        }
        output = string(abi.encodePacked(output, cache));

        //parts[18]
        cache = '</text><text x="10" y="200" class="base">';
        output = string(abi.encodePacked(output, cache));

        // parts[19]
        cache = string(
            abi.encodePacked(
                "Acitvate ",
                toString(metadata2.activateArtifactAmount),
                " artifact"
            )
        );

        if (metadata2.activateArtifactAmount > 1) {
            cache = string(abi.encodePacked(cache, "s"));
        }
        output = string(abi.encodePacked(output, cache));

        // parts[20]
        cache = '</text><text x="10" y="220" class="base">';
        output = string(abi.encodePacked(output, cache));

        // parts[21]
        cache = string(
            abi.encodePacked(
                "Drop ",
                toString(metadata2.dropBombAmount),
                " bomb"
            )
        );

        if (metadata2.dropBombAmount > 1) {
            cache = string(abi.encodePacked(cache, "s"));
        }

        output = string(abi.encodePacked(output, cache));

        // parts[22]
        cache = '</text><text x="10" y="240" class="base">';
        output = string(abi.encodePacked(output, cache));

        // parts[23]
        cache = string(
            abi.encodePacked("Pink ", toString(metadata2.pinkAmount), " planet")
        );

        if (metadata2.pinkAmount > 1) {
            cache = string(abi.encodePacked(cache, "s"));
        }

        output = string(abi.encodePacked(output, cache));

        // parts[24]
        cache = '</text><text x="10" y="260" class="base">';
        output = string(abi.encodePacked(output, cache));

        // parts[25]
        if (metadata2.pinkedAmount < 2) {
            cache = string(
                abi.encodePacked(
                    toString(metadata2.pinkedAmount),
                    " planet destroyed by others"
                )
            );
        } else {
            cache = string(
                abi.encodePacked(
                    toString(metadata2.pinkedAmount),
                    " planets destroyed by others"
                )
            );
        }

        output = string(abi.encodePacked(output, cache));

        // parts[26]
        cache = '</text><text x="10" y="280" class="base">';
        output = string(abi.encodePacked(output, cache));

        // parts[27] => round 4 
        // cache = '</text><text x="10" y="300" class="base">';
        // output = string(abi.encodePacked(output, cache));

        // parts[28]
        if (metadata2.ifFirstMythicArtifactOwner) {
            cache = string(abi.encodePacked(unicode"🌟"));
        } else if (metadata2.ifFirstBurnLocationOperator) {
            cache = string(abi.encodePacked(unicode"💣"));
        } else if (metadata2.ifFirstKardashevOperator) {
            cache = string(abi.encodePacked(unicode"🔷"));
        }
        output = string(abi.encodePacked(output, cache));

        // parts[28]
        cache = "</text></svg>";
        output = string(abi.encodePacked(output, cache));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Ticket #',
                        toString(tokenId),
                        '", "description": "Ares Epic is the ticket to enter new world.", "image": "data:image/svg+xml;base64,',
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
