// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

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
    event Message(
        address owner,
        uint tokenId,
        address playerAddr,
        string teamName,
        uint moreGold,
        uint moreGlory
    );

    bool public frozen;

    uint private _tokenIds;
    mapping(uint256 => address) public burnerWalletAddress;
    mapping(uint256 => string) public teamName;
    mapping(uint256 => uint256) public gold;
    mapping(uint256 => uint256) public glory;
    mapping(address => uint256) public rank;

    modifier notFrozen() {
        require(!frozen, "already frozen");
        _;
    }

    constructor() ERC721("ARESLoot v0.1.1", "ARES") Ownable() {
        frozen = false;
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

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(tokenId > 0 && tokenId <= _tokenIds, "Out of limit");

        string[18] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: #fee761; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="#3a4466" /><text x="10" y="20" class="base">';

        parts[1] = string(abi.encodePacked("DF ARES v0.1 Round 1"));

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = string(abi.encodePacked("Ticket # ", toString(tokenId)));

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = string(
            abi.encodePacked(toAsciiString(burnerWalletAddress[tokenId]))
        );

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = string(abi.encodePacked("Adventurer"));

        parts[8] = '</text><text x="10" y="100" class="base">';
        if (
            keccak256(abi.encodePacked((teamName[tokenId]))) ==
            keccak256(abi.encodePacked(("")))
        ) parts[9] = string(abi.encodePacked("DF ARES Community"));
        else parts[9] = string(abi.encodePacked("Team: ", teamName[tokenId]));
        parts[10] = '</text><text x="10" y="120" class="base">';
        parts[11] = string(abi.encodePacked("Gold +", toString(gold[tokenId])));
        parts[12] = '</text><text x="10" y="140" class="base">';
        parts[13] = string(
            abi.encodePacked("Glory +", toString(glory[tokenId]))
        );

        parts[14] = '</text><text x="10" y="160" class="base">';
        if (rank[burnerWalletAddress[tokenId]] == 0) {
            parts[15] = string(abi.encodePacked(""));
        } else
            parts[15] = string(
                abi.encodePacked(
                    "Rank # ",
                    toString(rank[burnerWalletAddress[tokenId]])
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

    function mint(
        address _burnerWalletAddress,
        string memory _teamName,
        uint _gold,
        uint _glory
    ) public payable nonReentrant notFrozen {
        uint amount = (_gold + _glory) * 1 ether;
        require(msg.value == amount, "mint: eq");
        ++_tokenIds;
        uint tokenId = _tokenIds;
        _safeMint(_msgSender(), tokenId);
        burnerWalletAddress[tokenId] = _burnerWalletAddress;

        teamName[tokenId] = _teamName;
        gold[tokenId] = _gold;
        glory[tokenId] = _glory;
        emit Message(
            _msgSender(),
            tokenId,
            burnerWalletAddress[tokenId],
            _teamName,
            _gold,
            _glory
        );
    }

    function setTeamName(
        uint tokenId,
        string memory _teamName
    ) public notFrozen {
        require(
            ownerOf(tokenId) == _msgSender() || owner() == _msgSender(),
            "only owner or admin"
        );
        teamName[tokenId] = _teamName;
    }

    function more(
        uint tokenId,
        uint _moreGold,
        uint _moreGlory
    ) public payable nonReentrant notFrozen {
        require(ownerOf(tokenId) == _msgSender(), "only ticket owner");

        uint amount = (_moreGold + _moreGlory) * 1 ether;
        require(msg.value == amount, "mint: eq");

        gold[tokenId] += _moreGold;
        glory[tokenId] += _moreGlory;

        emit Message(
            _msgSender(),
            tokenId,
            burnerWalletAddress[tokenId],
            teamName[tokenId],
            _moreGold,
            _moreGlory
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
