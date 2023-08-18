// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

/**
 * @title Colin
 * @author Colin Platt
 * @notice WARNING: This contract has NOT been audited and is highly experimental.
 *         Frindex is in no way intended to be used for investment purposes.
 *         Interacting with this contract may lead to irreversible loss of funds.
 *         Use at your own risk.
 */

contract Colin is ERC20, Ownable {
    IFriendtechSharesV1 public immutable friendShares;

    struct ShareBlock {
        address subject;
        uint96 shares; //number of shares units to create/redeem
    }

    ShareBlock[] public shareBlocksBuying;
    uint256 public shareBlocksBuyingLength;
    ShareBlock[] public shareBlocksSelling;
    uint256 public shareBlocksSellingLength;

    uint8 public constant FEE = 1; //1% on create/redeem
    bool public delegateCallRightsBurned = false;
    bool public useBuyingBlock = true;

    constructor(address _friendShares) {
        friendShares = IFriendtechSharesV1(_friendShares);
        friendShares.buyShares(address(this), 1); // buy one share to initialize the supply
        _initializeOwner(msg.sender);
    }

    receive() external payable {}

    /*//////////////////////////////////////////////////////////////
                            ERC20 OVERRIDES
    //////////////////////////////////////////////////////////////*/

    function name() public pure override returns (string memory) {
        return "Colin Shares";
    }

    function symbol() public pure override returns (string memory) {
        return unicode"COLIN";
    }

    // prevent user from sending the token to the contract address
    function _beforeTokenTransfer(address, address to, uint256) internal override {
        require(to != address(this), "Cannot transfer to contract address");
    }

    /*//////////////////////////////////////////////////////////////
                          CREATION/REDEMPTION
    //////////////////////////////////////////////////////////////*/

    function create(uint256 blocksCreating) public payable {
        uint256 costOfBlocks = getBlockBuyCost(blocksCreating);

        uint256 valueAfterFee = msg.value * (100 - FEE) / 100;

        require(valueAfterFee >= costOfBlocks, "Insufficient payment");

        // dev works hard and deserves to be paid
        SafeTransferLib.safeTransferETH(owner(), msg.value - valueAfterFee);

        buyBlock(blocksCreating, valueAfterFee);

        _mint(msg.sender, blocksCreating * 100 ether);
    }

    function redeem(uint256 tokensRedeeming) public {
        uint256 blocksToRedeem = (tokensRedeeming / 100 ether);

        uint256 valueToRedeem = getBlockSellValue(blocksToRedeem);

        _burn(msg.sender, tokensRedeeming);

        sellBlock(blocksToRedeem);

        // dev works hard and deserves to be paid
        SafeTransferLib.safeTransferETH(owner(), valueToRedeem * FEE / 100);

        SafeTransferLib.safeTransferETH(msg.sender, valueToRedeem * (100 - FEE) / 100);
    }

    /*//////////////////////////////////////////////////////////////
                          BLOCK COSTS
    //////////////////////////////////////////////////////////////*/

    function getBlockBuyCost(uint256 amount) public view returns (uint256 blockCost) {
        ShareBlock[] memory _shareBlocks = shareBlocksBuying;

        for (uint256 i = 0; i < _shareBlocks.length; i++) {
            blockCost += friendShares.getBuyPriceAfterFee(_shareBlocks[i].subject, _shareBlocks[i].shares * amount);
        }
    }

    // this is useful for calculating the cost of creating a block on the frontend
    function getBlockCostWithFee(uint256 amount) public view returns (uint256) {
        return getBlockBuyCost(amount) * 100 / (100 - FEE) + 1e3;
    }

    function getBlockSellValue(uint256 amount) public view returns (uint256 blockValue) {
        // unless there is a specific change marked for selling block, we should create and redeem with the same blocks
        ShareBlock[] memory _shareBlocks = useBuyingBlock ? shareBlocksBuying : shareBlocksSelling;

        for (uint256 i = 0; i < _shareBlocks.length; i++) {
            blockValue += friendShares.getSellPriceAfterFee(_shareBlocks[i].subject, _shareBlocks[i].shares * amount);
        }
    }

    /*//////////////////////////////////////////////////////////////
                          TRADING SHARES
    //////////////////////////////////////////////////////////////*/

    function buyBlock(uint256 numberOfBlocks, uint256 spend) internal {
        for (uint256 i = 0; i < shareBlocksBuyingLength; i++) {
            uint256 subjectCost =
                friendShares.getBuyPriceAfterFee(shareBlocksBuying[i].subject, shareBlocksBuying[i].shares);
            friendShares.buyShares{value: subjectCost}(shareBlocksBuying[i].subject, shareBlocksBuying[i].shares);
        }
    }

    function sellBlock(uint256 numberOfBlocks) internal {
        if (useBuyingBlock) {
            uint256 length = shareBlocksBuyingLength;
            for (uint256 i = 0; i < length; i++) {
                friendShares.sellShares(shareBlocksBuying[i].subject, shareBlocksBuying[i].shares);
            }
        } else {
            uint256 length = shareBlocksSellingLength;
            for (uint256 i = 0; i < length; i++) {
                friendShares.sellShares(shareBlocksSelling[i].subject, shareBlocksSelling[i].shares);
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                    OWNER CONTROLLED BLOCK OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev The owned needs to be careful to manage valuation differences betwee buying blocks and selling blocks as large deviations will be arbitraged in the creation/redemption process
    function amendBlockBuying(uint256 index, ShareBlock memory newShareBlock) public onlyOwner {
        require(index < shareBlocksBuyingLength, "Index out of bounds");
        shareBlocksBuying[index] = newShareBlock;
    }

    function amendBlockSelling(uint256 index, ShareBlock memory newShareBlock) public onlyOwner {
        require(index < shareBlocksSellingLength, "Index out of bounds");
        shareBlocksSelling[index] = newShareBlock;
    }

    // wholesale updates to blocks for buying and selling
    function setBlockBuying(ShareBlock[] memory newShareBlockBuying) public onlyOwner {
        require(newShareBlockBuying.length <= 50, "Too many blocks");

        // add new blocks
        for (uint256 i = 0; i < newShareBlockBuying.length; i++) {
            if (i < shareBlocksBuyingLength) {
                shareBlocksBuying[i] = newShareBlockBuying[i];
            } else {
                shareBlocksBuying.push(newShareBlockBuying[i]);
            }
        }
        shareBlocksBuyingLength = newShareBlockBuying.length;
    }

    function setBlockSelling(ShareBlock[] memory newShareBlockSelling) public onlyOwner {
        require(newShareBlockSelling.length <= 50, "Too many blocks");

        // add new blocks
        for (uint256 i = 0; i < newShareBlockSelling.length; i++) {
            if (i < shareBlocksSellingLength) {
                shareBlocksSelling[i] = newShareBlockSelling[i];
            } else {
                shareBlocksSelling.push(newShareBlockSelling[i]);
            }
        }
        shareBlocksSellingLength = newShareBlockSelling.length;
    }

    function setUseBuyingBlock(bool _useBuyingBlock) public onlyOwner {
        useBuyingBlock = _useBuyingBlock;
    }

    function clearStuckETH() public onlyOwner {
        SafeTransferLib.safeTransferETH(owner(), address(this).balance);
    }

    function clearStuckShares(address sharesSubject, uint256 amount) public onlyOwner {
        friendShares.sellShares(sharesSubject, amount);
    }

    function burnDelegateCallRights() public onlyOwner {
        delegateCallRightsBurned = true;
    }

    // this is a dangerous function that allows the owner to call any function as the friendShares contract. It is intended for use if there is a claim for an airdrop.
    function DANGEROUS_owner_delegateCall(address target, bytes calldata data) public onlyOwner {
        require(!delegateCallRightsBurned, "Delegate call rights burned");
        (bool success, bytes memory returnData) = target.delegatecall(data);
        require(success, string(returnData));
    }
}
