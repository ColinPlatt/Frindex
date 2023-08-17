// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "src/Frindex.sol";
import {FriendtechSharesV1} from "src/utils/FriendtechSharesV1.sol";

contract FrindexTest is Test {
    string RPC = vm.envString("RPC_URL");
    uint256 fork;

    FriendtechSharesV1 public ft = FriendtechSharesV1(0xCF205808Ed36593aa40a44F10c7f7C2F67d4A4d4);

    Frindex public frindex;

    address public deployer = address(0xad1);

    function setUp() public {
        fork = vm.createSelectFork(RPC);

        vm.startPrank(deployer);
        frindex = new Frindex(address(ft));
        vm.stopPrank();
    }

    function testDeployment() public {
        assertEq(frindex.name(), "Frindex");
        assertEq(frindex.symbol(), unicode"🫂");
        assertEq(frindex.owner(), deployer);
        emit log_named_uint("friend.tech balance (in ETH)", address(ft).balance / 1 ether);
    }

    function _setInitialBlocks() internal {
        vm.startPrank(deployer);
        Frindex.ShareBlock[] memory blocks = new Frindex.ShareBlock[](5);

        blocks[0] = Frindex.ShareBlock(0xFd7232E66A69E1Ae01e1E0ea8faB4776E2d325a9, 1);
        blocks[1] = Frindex.ShareBlock(0x4E5F7E4a774BD30B9bDca7Eb84CE3681A71676e1, 1);
        blocks[2] = Frindex.ShareBlock(0x63CE139Ed34d2BB075841F88D1f5B4282F31F2d9, 1);
        blocks[3] = Frindex.ShareBlock(0xf215EAB5884A5fa1773Db8976CF5c7fBC00e9Ac4, 3);
        blocks[4] = Frindex.ShareBlock(0xeeC3d7037eBa9cCe29FFF7b451Ea6E3E0D2ec475, 10);
        frindex.setBlockBuying(blocks);

        blocks[0] = Frindex.ShareBlock(0xFd7232E66A69E1Ae01e1E0ea8faB4776E2d325a9, 1);
        blocks[1] = Frindex.ShareBlock(0x4E5F7E4a774BD30B9bDca7Eb84CE3681A71676e1, 1);
        blocks[2] = Frindex.ShareBlock(0x63CE139Ed34d2BB075841F88D1f5B4282F31F2d9, 1);
        blocks[3] = Frindex.ShareBlock(0xf215EAB5884A5fa1773Db8976CF5c7fBC00e9Ac4, 2);
        blocks[4] = Frindex.ShareBlock(0xeeC3d7037eBa9cCe29FFF7b451Ea6E3E0D2ec475, 1);
        frindex.setBlockSelling(blocks);
        frindex.setUseBuyingBlock(false);
        vm.stopPrank();
    }

    function testSetBlocks() public {
        _setInitialBlocks();
        assertEq(frindex.shareBlocksBuyingLength(), 5);
        emit log_named_uint("buying block price", frindex.getBlockBuyCost(1));

        assertEq(frindex.shareBlocksSellingLength(), 5);
        emit log_named_uint("selling block price", frindex.getBlockSellValue(1));
    }

    function testCreateAndRedeem() public {
        _setInitialBlocks();
        address bob = address(0xb0b);

        vm.startPrank(bob);
        vm.deal(bob, 100 ether);
        uint256 cost = frindex.getBlockCostWithFee(1);
        frindex.create{value: cost}(1);
        assertEq(frindex.balanceOf(bob), 100 ether);
        assertEq(frindex.totalSupply(), 100 ether);
        assertEq(ft.sharesBalance(0xFd7232E66A69E1Ae01e1E0ea8faB4776E2d325a9, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x4E5F7E4a774BD30B9bDca7Eb84CE3681A71676e1, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x63CE139Ed34d2BB075841F88D1f5B4282F31F2d9, address(frindex)), 1);
        assertEq(ft.sharesBalance(0xf215EAB5884A5fa1773Db8976CF5c7fBC00e9Ac4, address(frindex)), 3);
        assertEq(ft.sharesBalance(0xeeC3d7037eBa9cCe29FFF7b451Ea6E3E0D2ec475, address(frindex)), 10);

        cost = frindex.getBlockCostWithFee(1);
        frindex.create{value: cost}(1);
        assertEq(frindex.balanceOf(bob), 200 ether);
        assertEq(frindex.totalSupply(), 200 ether);
        assertEq(ft.sharesBalance(0xFd7232E66A69E1Ae01e1E0ea8faB4776E2d325a9, address(frindex)), 2);
        assertEq(ft.sharesBalance(0x4E5F7E4a774BD30B9bDca7Eb84CE3681A71676e1, address(frindex)), 2);
        assertEq(ft.sharesBalance(0x63CE139Ed34d2BB075841F88D1f5B4282F31F2d9, address(frindex)), 2);
        assertEq(ft.sharesBalance(0xf215EAB5884A5fa1773Db8976CF5c7fBC00e9Ac4, address(frindex)), 6);
        assertEq(ft.sharesBalance(0xeeC3d7037eBa9cCe29FFF7b451Ea6E3E0D2ec475, address(frindex)), 20);

        emit log_named_uint("selling block price", frindex.getBlockSellValue(1));
        frindex.redeem(100 ether);

        assertEq(frindex.balanceOf(bob), 100 ether);
        assertEq(frindex.totalSupply(), 100 ether);
        assertEq(ft.sharesBalance(0xFd7232E66A69E1Ae01e1E0ea8faB4776E2d325a9, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x4E5F7E4a774BD30B9bDca7Eb84CE3681A71676e1, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x63CE139Ed34d2BB075841F88D1f5B4282F31F2d9, address(frindex)), 1);
        assertEq(ft.sharesBalance(0xf215EAB5884A5fa1773Db8976CF5c7fBC00e9Ac4, address(frindex)), 4);
        assertEq(ft.sharesBalance(0xeeC3d7037eBa9cCe29FFF7b451Ea6E3E0D2ec475, address(frindex)), 19);

        vm.stopPrank();
    }
}
