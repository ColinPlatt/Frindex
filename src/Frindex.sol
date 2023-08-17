// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FriendtechSharesV1} from "./utils/FriendtechSharesV1.sol";
import {ERC20, Ownable, SafeTransferLib} from "solady/Milady.sol";

interface IFriendtechSharesV1 {
    function sharesBalance(address sharesSubject, address holder) external view returns (uint256);
    function sharesSupply(address sharesSubject) external view returns (uint256);
    function getPrice(uint256 supply, uint256 amount) external pure returns (uint256);
    function getBuyPrice(address sharesSubject, uint256 amount) external view returns (uint256);
    function getSellPrice(address sharesSubject, uint256 amount) external view returns (uint256);
    function getBuyPriceAfterFee(address sharesSubject, uint256 amount) external view returns (uint256);
    function getSellPriceAfterFee(address sharesSubject, uint256 amount) external view returns (uint256);
    function buyShares(address sharesSubject, uint256 amount) external payable;
    function sellShares(address sharesSubject, uint256 amount) external;
}

contract Frindex is ERC20, Ownable {
    IFriendtechSharesV1 public immutable friendShares;

    struct FriendWeight {
        address subject;
        uint96 weight; //weight in bps, rounds down
    }

    FriendWeight[] public currentFriendWeights;
    FriendWeight[] public nextFriendWeights;
    uint32 lastUpdate; //timestamp of last weight update

    constructor(address _friendShares) {
        friendShares = IFriendtechSharesV1(_friendShares);
        _initializeOwner(msg.sender);
    }

    function name() public pure override returns (string memory) {
        return "Frindex";
    }

    function symbol() public pure override returns (string memory) {
        return unicode"🫂";
    }

    /*//////////////////////////////////////////////////////////////
                          CREATION/REDEMPTION
    //////////////////////////////////////////////////////////////*/

    function create(uint256 amount) public payable {
        _mint(msg.sender, amount);
    }

    function redeem(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /*//////////////////////////////////////////////////////////////
                          SHARES/TOKENS
    //////////////////////////////////////////////////////////////*/

    function getHoldings() public view returns (address[] memory shareSubjects, uint256[] memory shares) {
        uint256 length = currentFriendWeights.length;
        shareSubjects = new address[](length);
        shares = new uint256[](length);
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                shareSubjects[i] = currentFriendWeights[i].subject;
                shares[i] = friendShares.sharesBalance(shareSubjects[i], address(this));
            }
        }
    }

    // calculate the total buy value of the portfolio, exclusive of trading fees
    function portfolioBuyValue() public view returns (uint256 value) {
        (address[] memory shareSubjects, uint256[] memory shares) = getHoldings();
        uint256 length = shareSubjects.length;
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                value += friendShares.getBuyPrice(shareSubjects[i], shares[i]);
            }
        }
    }

    // calculate the total sell value of the portfolio, exclusive of trading fees
    function portfolioSellValue() public view returns (uint256 value) {
        (address[] memory shareSubjects, uint256[] memory shares) = getHoldings();
        uint256 length = shareSubjects.length;
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                value += friendShares.getSellPrice(shareSubjects[i], shares[i]);
            }
        }
    }

    // calculate the total theorectical mid value of the portfolio, exclusive of trading fees
    function portfolioMidValue() public view returns (uint256 value) {
        (address[] memory shareSubjects, uint256[] memory shares) = getHoldings();
        uint256 length = shareSubjects.length;
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                // we calculate half the reduced amount to arrive at the difference between the buy and sell price
                value += friendShares.getPrice(friendShares.sharesSupply(shareSubjects[i]) - (shares[i] / 2), shares[i]);
            }
        }
    }
}
