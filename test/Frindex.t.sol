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
        assertEq(frindex.name(), "Frindex v0");
        assertEq(frindex.symbol(), unicode"🫂V0");
        assertEq(frindex.owner(), deployer);
        emit log_named_uint("friend.tech balance (in ETH)", address(ft).balance / 1 ether);
    }

    function _setInitialBlocks() internal {
        vm.startPrank(deployer);
        Frindex.ShareBlock[] memory blocks = new Frindex.ShareBlock[](28);

        blocks[0] = Frindex.ShareBlock(0xb35640273f0129DC787a141ee91D05E35F72ecE8, 1);
        blocks[1] = Frindex.ShareBlock(0x7Deab84357423Ce827D5ad260E283dd77A0C552D, 1);
        blocks[2] = Frindex.ShareBlock(0x386eCE50eF2f6a39bA0105C59191fe2930FbBddd, 1);
        blocks[3] = Frindex.ShareBlock(0x09A517aBBad39895b0b538E4b16B2BC9ed58D943, 1);
        blocks[4] = Frindex.ShareBlock(0x7fca2356bE8657D61012650A9A0A17b4dF0B5078, 1);
        blocks[5] = Frindex.ShareBlock(0x30d556E5e17b84538C44abAaA00E87B1ECa6c090, 1);
        blocks[6] = Frindex.ShareBlock(0x918684777D5bD27408F185666CDA71C2E97bE835, 1);
        blocks[7] = Frindex.ShareBlock(0xf70D8A5c563A486f3DA53EE5A2ae922f1B611697, 1);
        blocks[8] = Frindex.ShareBlock(0x078F31c09941607F0Af3f9e35949CB598C01c425, 1);
        blocks[9] = Frindex.ShareBlock(0x6f70ecEF3af81cCCaDdB2C41c8bBdC2419Db3b14, 1);
        blocks[10] = Frindex.ShareBlock(0xc9Cc71aA248C28600A71eea575A9893405b38Cc5, 1);
        blocks[11] = Frindex.ShareBlock(0xf4Cdeb375e478Cbf81334213ACD3adCe5537D396, 1);
        blocks[12] = Frindex.ShareBlock(0x9393c6a674a0De57F3Fe341dd178000553b7fF35, 1);
        blocks[13] = Frindex.ShareBlock(0x12c36De562f721D456802DE10e3f307A6Fc68089, 1);
        blocks[14] = Frindex.ShareBlock(0xB80eE93e1d49349C8f76f4c824D99ef1cB1CeD7A, 1);
        blocks[15] = Frindex.ShareBlock(0xc889c4c043B7dcD4D5ef118B52ED97dF899e5910, 1);
        blocks[16] = Frindex.ShareBlock(0x9E2F2501b4EB4A0Cc5166a272B71acDaE16ed969, 1);
        blocks[17] = Frindex.ShareBlock(0x292d461d3E1Aff6C3146Cd316a62246C9b9AD3fb, 1);
        blocks[18] = Frindex.ShareBlock(0x78765c382307a80f3211f83dAdA664fA32713a44, 1);
        blocks[19] = Frindex.ShareBlock(0x8B631E33D36dF488e3D002B221F3Bf8383904787, 1);
        blocks[20] = Frindex.ShareBlock(0x7Ef8cc1C97F42CeF5eEF69577ec5c7788cA19a5F, 1);
        blocks[21] = Frindex.ShareBlock(0x1f2485f762fE5A9700cb6a36d64EFaFf80bA3157, 1);
        blocks[22] = Frindex.ShareBlock(0xB5Cc816B1bA55c89659eA730439f0c385E434737, 1);
        blocks[23] = Frindex.ShareBlock(0xB7Ae9bf2825bcC4b4971D3CEE683FFca58C84133, 1);
        blocks[24] = Frindex.ShareBlock(0xFEA0047b5Bc15E8106Fc53A96532705076af9A79, 1);
        blocks[25] = Frindex.ShareBlock(0xF9B7cF4BE6F4Cde37Dd1A5b75187d431D94a4Fcc, 1);
        blocks[26] = Frindex.ShareBlock(0x3d531481E65F31412495Bedadb06EFc8Ea986581, 1);
        blocks[27] = Frindex.ShareBlock(0x956b946cAf2be5932f1Dc02e90502055dB8FB9ec, 1);
        frindex.setBlockBuying(blocks);

        /*
        blocks[0] = Frindex.ShareBlock(0xb35640273f0129DC787a141ee91D05E35F72ecE8, 1);
        blocks[1] = Frindex.ShareBlock(0x7Deab84357423Ce827D5ad260E283dd77A0C552D, 1);
        blocks[2] = Frindex.ShareBlock(0x386eCE50eF2f6a39bA0105C59191fe2930FbBddd, 1);
        blocks[3] = Frindex.ShareBlock(0x09A517aBBad39895b0b538E4b16B2BC9ed58D943, 1);
        blocks[4] = Frindex.ShareBlock(0x7fca2356bE8657D61012650A9A0A17b4dF0B5078, 1);
        blocks[5] = Frindex.ShareBlock(0x30d556E5e17b84538C44abAaA00E87B1ECa6c090, 1);
        blocks[6] = Frindex.ShareBlock(0x918684777D5bD27408F185666CDA71C2E97bE835, 1);
        blocks[7] = Frindex.ShareBlock(0xf70D8A5c563A486f3DA53EE5A2ae922f1B611697, 1);
        blocks[8] = Frindex.ShareBlock(0x078F31c09941607F0Af3f9e35949CB598C01c425, 1);
        blocks[9] = Frindex.ShareBlock(0x6f70ecEF3af81cCCaDdB2C41c8bBdC2419Db3b14, 1);
        blocks[10] = Frindex.ShareBlock(0xc9Cc71aA248C28600A71eea575A9893405b38Cc5, 1);
        blocks[11] = Frindex.ShareBlock(0xf4Cdeb375e478Cbf81334213ACD3adCe5537D396, 1);
        blocks[12] = Frindex.ShareBlock(0x9393c6a674a0De57F3Fe341dd178000553b7fF35, 1);
        blocks[13] = Frindex.ShareBlock(0x12c36De562f721D456802DE10e3f307A6Fc68089, 1);
        blocks[14] = Frindex.ShareBlock(0xB80eE93e1d49349C8f76f4c824D99ef1cB1CeD7A, 1);
        blocks[15] = Frindex.ShareBlock(0xc889c4c043B7dcD4D5ef118B52ED97dF899e5910, 1);
        blocks[16] = Frindex.ShareBlock(0x9E2F2501b4EB4A0Cc5166a272B71acDaE16ed969, 1);
        blocks[17] = Frindex.ShareBlock(0x292d461d3E1Aff6C3146Cd316a62246C9b9AD3fb, 1);
        blocks[18] = Frindex.ShareBlock(0x78765c382307a80f3211f83dAdA664fA32713a44, 1);
        blocks[19] = Frindex.ShareBlock(0x8B631E33D36dF488e3D002B221F3Bf8383904787, 1);
        blocks[20] = Frindex.ShareBlock(0x7Ef8cc1C97F42CeF5eEF69577ec5c7788cA19a5F, 1);
        blocks[21] = Frindex.ShareBlock(0x1f2485f762fE5A9700cb6a36d64EFaFf80bA3157, 1);
        blocks[22] = Frindex.ShareBlock(0xB5Cc816B1bA55c89659eA730439f0c385E434737, 1);
        blocks[23] = Frindex.ShareBlock(0xB7Ae9bf2825bcC4b4971D3CEE683FFca58C84133, 1);
        blocks[24] = Frindex.ShareBlock(0xFEA0047b5Bc15E8106Fc53A96532705076af9A79, 1);
        blocks[25] = Frindex.ShareBlock(0xF9B7cF4BE6F4Cde37Dd1A5b75187d431D94a4Fcc, 1);
        blocks[26] = Frindex.ShareBlock(0x3d531481E65F31412495Bedadb06EFc8Ea986581, 1);
        blocks[27] = Frindex.ShareBlock(0x956b946cAf2be5932f1Dc02e90502055dB8FB9ec, 1);
        frindex.setBlockSelling(blocks);
        frindex.setUseBuyingBlock(true);
        */
        vm.stopPrank();
    }

    function testSetBlocks() public {
        _setInitialBlocks();
        assertEq(frindex.shareBlocksBuyingLength(), 28);
        emit log_named_uint("buying block price", frindex.getBlockBuyCost(1));

        assertEq(frindex.shareBlocksSellingLength(), 0);
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
        assertEq(ft.sharesBalance(0xb35640273f0129DC787a141ee91D05E35F72ecE8, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x7Deab84357423Ce827D5ad260E283dd77A0C552D, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x386eCE50eF2f6a39bA0105C59191fe2930FbBddd, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x09A517aBBad39895b0b538E4b16B2BC9ed58D943, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x7fca2356bE8657D61012650A9A0A17b4dF0B5078, address(frindex)), 1);

        cost = frindex.getBlockCostWithFee(1);
        frindex.create{value: cost}(1);
        assertEq(frindex.balanceOf(bob), 200 ether);
        assertEq(frindex.totalSupply(), 200 ether);
        assertEq(ft.sharesBalance(0xb35640273f0129DC787a141ee91D05E35F72ecE8, address(frindex)), 2);
        assertEq(ft.sharesBalance(0x7Deab84357423Ce827D5ad260E283dd77A0C552D, address(frindex)), 2);
        assertEq(ft.sharesBalance(0x386eCE50eF2f6a39bA0105C59191fe2930FbBddd, address(frindex)), 2);
        assertEq(ft.sharesBalance(0x09A517aBBad39895b0b538E4b16B2BC9ed58D943, address(frindex)), 2);
        assertEq(ft.sharesBalance(0x7fca2356bE8657D61012650A9A0A17b4dF0B5078, address(frindex)), 2);

        emit log_named_uint("selling block price", frindex.getBlockSellValue(1));
        frindex.redeem(100 ether);

        assertEq(frindex.balanceOf(bob), 100 ether);
        assertEq(frindex.totalSupply(), 100 ether);
        assertEq(ft.sharesBalance(0xb35640273f0129DC787a141ee91D05E35F72ecE8, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x7Deab84357423Ce827D5ad260E283dd77A0C552D, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x386eCE50eF2f6a39bA0105C59191fe2930FbBddd, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x09A517aBBad39895b0b538E4b16B2BC9ed58D943, address(frindex)), 1);
        assertEq(ft.sharesBalance(0x7fca2356bE8657D61012650A9A0A17b4dF0B5078, address(frindex)), 1);

        vm.stopPrank();
    }
}
