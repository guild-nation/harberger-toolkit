// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, stdStorage, StdStorage} from "forge-std/Test.sol";

import {AddressBook} from "./utils/AddressBook.sol";

import "../src/ERC1924.sol";

contract ERC1924Test is Test, AddressBook {
    using stdStorage for StdStorage;

    ERC1924 private nft;
    uint256 private price;

    address addr = address(this);

    function setUp() public {
        vm.startPrank(OWNER);
        nft = new ERC1924("MockNft", "MNFT", "https://ipfs.io/", 10_000, 365 days, 10_00, 30 days, 5_00, BOB, 1_00);
        price = 1 ether;
        vm.stopPrank();
    }

    /// BASE

    function test_base_Constructor() public {
        assertEq(nft.owner(), OWNER);
        assertEq(nft.name(), "MockNft");
        assertEq(nft.symbol(), "MNFT");
        assertEq(nft.baseURI(), "https://ipfs.io/");
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.maxSupply(), 10_000);
        assertEq(nft.taxPeriod(), 365 days);
        assertEq(nft.taxNumerator(), 10_00);
        assertEq(nft.minPeriodCovered(), 30 days);
        assertEq(nft.previousHolderShare(), 5_00);
        assertEq(nft.benefactorShare(), 1_00);
    }

    /// Admin

    function test_setMinPeriodCovered_AsOwner() public {
        vm.startPrank(OWNER);
        nft.setMinPeriodCovered(10 days);
        assertEq(nft.minPeriodCovered(), 10 days);
        vm.stopPrank();
    }

    function test_setMinPeriodCovered_RevertIf_NonOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert("UNAUTHORIZED");
        nft.setMinPeriodCovered(10 days);
        vm.stopPrank();
    }

    function test_setTaxNumerator_AsOwner() public {
        vm.startPrank(OWNER);
        nft.setTaxNumerator(5_00);
        assertEq(nft.taxNumerator(), 5_00);
        vm.stopPrank();
    }

    function test_setTaxNumerator_RevertIf_NonOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert("UNAUTHORIZED");
        nft.setTaxNumerator(5_00);
        vm.stopPrank();
    }

    function test_setBaseURI_AsOwner() public {
        vm.startPrank(OWNER);
        nft.setBaseURI("https://example.com/");
        assertEq(nft.baseURI(), "https://example.com/");
        vm.stopPrank();
    }

    function test_setBaseURI_RevertIf_NonOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert("UNAUTHORIZED");
        nft.setBaseURI("https://example.com/");
        vm.stopPrank();
    }

    function test_withdrawBenefactor() public {
        nft.mint{value: price}(price);

        skip(1 days);
        nft.collectTax(addr);

        bool success = nft.withdrawBenefactor();
        assertEq(success, true);

        uint256 balance = address(BOB).balance;
        assertEq(balance, price * 1 days * 10_00 / 365 days / 100_00);
    }

    function test_setBenefactor_AsOwner() public {
        assertEq(nft.benefactor(), BOB);
        vm.startPrank(OWNER);
        nft.setBenefactor(ALICE);
        vm.stopPrank();
        assertEq(nft.benefactor(), ALICE);
    }

    function test_setBenefactor_AsBenefactor() public {
        assertEq(nft.benefactor(), BOB);
        vm.startPrank(BOB);
        nft.setBenefactor(ALICE);
        vm.stopPrank();
        assertEq(nft.benefactor(), ALICE);
    }

    function test_setBenefactor_RevertIf_NotAuthorized() public {
        vm.expectRevert(ERC1924.NotAuthorized.selector);
        nft.setBenefactor(ALICE);
    }

    function test_setBenefactor_RevertIf_ZeroAddress() public {
        vm.startPrank(BOB);
        vm.expectRevert(ERC1924.ZeroAddress.selector);
        nft.setBenefactor(address(0x0));
        vm.stopPrank();
    }

    function test_setBenefactorShare_AsOwner() public {
        vm.startPrank(OWNER);
        uint256 prevShare = nft.benefactorShare();
        nft.setBenefactorShare(50_00);
        uint256 afterShare = nft.benefactorShare();
        vm.stopPrank();

        assertEq(prevShare, 1_00);
        assertEq(afterShare, 50_00);
    }

    function test_setBenefactorShare_RevertIf_NotOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert("UNAUTHORIZED");
        nft.setBenefactorShare(50_00);
        vm.stopPrank();
    }

    function test_setBenefactorShare_RevertIf_TooHigh() public {
        vm.startPrank(OWNER);
        vm.expectRevert(ERC1924.IncorrectFee.selector);
        nft.setBenefactorShare(200_00);
        
        nft.setPreviousHolderShare(80_00);
        vm.expectRevert(ERC1924.IncorrectFee.selector);
        nft.setBenefactorShare(21_00);
        vm.stopPrank();
    }

    function test_setPreviousHolderShare_AsOwner() public {
        vm.startPrank(OWNER);
        uint256 prevShare = nft.previousHolderShare();
        nft.setPreviousHolderShare(50_00);
        uint256 afterShare = nft.previousHolderShare();
        vm.stopPrank();

        assertEq(prevShare, 5_00);
        assertEq(afterShare, 50_00);
    }

    function test_setPreviousHolderShare_RevertIf_NotOwner() public {
        vm.startPrank(ALICE);
        vm.expectRevert("UNAUTHORIZED");
        nft.setPreviousHolderShare(50_00);
        vm.stopPrank();
    }

    function test_setPreviousHolderShare_RevertIf_TooHigh() public {
        vm.startPrank(OWNER);
        vm.expectRevert(ERC1924.IncorrectFee.selector);
        nft.setPreviousHolderShare(200_00);
        
        nft.setBenefactorShare(80_00);
        vm.expectRevert(ERC1924.IncorrectFee.selector);
        nft.setPreviousHolderShare(21_00);
        vm.stopPrank();
    }

    ///  Mint

    function test_mint_MintComplete() public {
        uint256 tokenId = nft.mint{value: price}(price);

        assertEq(tokenId, 1);
        assertEq(nft.balanceOf(addr), 1);
        assertEq(nft.ownerOf(1), addr);
        assertEq(address(nft).balance, price);
    }

    function test_mint_HarbergerState() public {
        assertEq(nft.deposits(addr), 0);
        assertEq(nft.lastCollections(addr), 0);
        assertEq(nft.totalCosts(addr), 0);
        assertEq(nft.valuations(1), 0);

        uint256 expectedCost = price * 10_00;
        nft.mint{value: price}(price);

        assertEq(nft.deposits(addr), price);
        assertEq(nft.lastCollections(addr), block.timestamp);
        assertEq(nft.totalCosts(addr), expectedCost);
        assertEq(nft.valuations(1), price);
    }

    function test_mint_RevertIf_MintWithoutValue() public {
        vm.expectRevert(ERC1924.InsufficientDeposit.selector);
        nft.mint(price);
    }

    function test_mint_RevertIf_InsufficientDeposit() public {
        uint256 minValue = price * 30 days * 10_00 / 365 days / 100_00;
        vm.expectRevert(ERC1924.InsufficientDeposit.selector);
        nft.mint{value: minValue - 1}(price);
    }

    function test_mint_RevertIf_MaxSupplyReached() public {
        uint256 slot = stdstore.target(address(nft)).sig("totalSupply()").find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(nft.maxSupply()));
        vm.store(address(nft), loc, mockedCurrentTokenId);

        vm.expectRevert(ERC1924.MaxSupply.selector);
        nft.mint{value: price}(1);
    }

    /// CollectTax

    function test_collect_CollectTax() public {
        nft.mint{value: price}(price);
        uint256 preTax = nft.deposits(addr);

        skip(1 hours);

        nft.collectTax(addr);
        uint256 postTax = nft.deposits(addr);

        assertEq(postTax, preTax - price * 1 hours * 10_00 / 365 days / 100_00);
        assertEq(nft.lastCollections(addr), block.timestamp);
    }

    function test_collect_FinalTax() public {
        nft.mint{value: price}(price);
        skip(3650 days);
        nft.collectTax(addr);

        assertEq(nft.deposits(addr), 0);
        assertEq(nft.lastCollections(addr), block.timestamp);
    }

    /// Foreclose

    function test_foreclose_Foreclose() public {
        nft.mint{value: price}(price);
        assertEq(nft.ownerOf(1), addr);
        assertEq(nft.valuations(1), price);
        assertEq(nft.balanceOf(addr), 1);
        assertEq(nft.balanceOf(address(nft)), 0);

        skip(3650 days + 1);
        nft.foreclose(1);

        assertEq(nft.ownerOf(1), address(nft));
        assertEq(nft.valuations(1), 0);
        assertEq(nft.balanceOf(addr), 0);
        assertEq(nft.balanceOf(address(nft)), 1);
    }

    function test_foreclose_RevertIf_NotDefaulted() public {
        nft.mint{value: price}(price);
        vm.expectRevert(ERC1924.NotDefaulted.selector);
        nft.foreclose(1);
        assertEq(nft.foreclosed(1), false);
    }

    function test_foreclose_CheckForeclosed() public {
        nft.mint{value: price}(price);
        assertEq(nft.foreclosed(1), false);

        skip(3650 days + 1);
        nft.foreclose(1);

        assertEq(nft.foreclosed(1), true);
    }

    function test_foreclose_CheckForeclosedPatron() public {
        nft.mint{value: price}(price);
        assertEq(nft.foreclosedPatron(addr), false);
        skip(3650 days + 1);
        assertEq(nft.foreclosedPatron(addr), true);
    }

    function test_foreclose_GetRemainingDeposit() public {
        nft.mint{value: price}(price);
        uint256 pre = nft.getRemainingDeposit(addr);
        assertEq(pre, price);

        skip(1 hours);

        uint256 post = nft.getRemainingDeposit(addr);
        assertEq(post, pre - price * 1 hours * 10_00 / 365 days / 100_00);

        skip(3650 days);

        assertEq(nft.getRemainingDeposit(addr), 0);
    }

    function test_foreclose_ForeclosureTime() public {
        nft.mint{value: price}(price);
        uint256 foreclosureTime = nft.foreclosureTime(1);
        uint256 expected = block.timestamp + 3650 days;
        assertEq(foreclosureTime, expected);
    }

    function test_foreclose_RevertIf_NonExistentToken() public {
        vm.expectRevert(ERC1924.NonExistentToken.selector);
        nft.foreclosureTime(100);
    }

    function test_foreclose_InfiniteForeclosureTime() public {
        assertEq(nft.foreclosureTimePatron(addr), type(uint256).max);
    }

    function test_foreclose_CheckForeclosureTime() public {
        nft.mint{value: price}(price);
        uint256 expected = block.timestamp + 3650 days;
        assertEq(nft.foreclosureTimePatron(addr), expected);
    }

    /// Transfer

    function test_transfer_RevertIf_TransferFrom() public {
        nft.mint{value: price}(price);
        vm.expectRevert(ERC1924.NonTransferable.selector);
        nft.transferFrom(addr, ALICE, 1);
    }

    function test_transfer_RevertIf_SafeTransferFrom() public {
        nft.mint{value: price}(price);
        vm.expectRevert(ERC1924.NonTransferable.selector);
        nft.safeTransferFrom(addr, ALICE, 1);
    }

    function test_transfer_RevertIf_SafeTransferFromCalldata() public {
        nft.mint{value: price}(price);
        vm.expectRevert(ERC1924.NonTransferable.selector);
        nft.safeTransferFrom(addr, ALICE, 1, "0x");
    }

    /// Refund

    function test_refund_RefundToken() public {
        nft.mint{value: price}(price);
        assertEq(nft.ownerOf(1), addr);
        assertEq(nft.valuations(1), price);
        assertEq(nft.balanceOf(addr), 1);
        assertEq(nft.balanceOf(address(nft)), 0);
        assertEq(nft.totalCosts(addr), price * 10_00);
        assertEq(nft.totalCosts(address(nft)), 0);

        nft.refundToken(1);
        assertEq(nft.ownerOf(1), address(nft));
        assertEq(nft.valuations(1), 0);
        assertEq(nft.balanceOf(addr), 0);
        assertEq(nft.balanceOf(address(nft)), 1);
        assertEq(nft.totalCosts(addr), 0);
        assertEq(nft.totalCosts(address(nft)), 0);
    }

    function test_refund_PreventForeclosure() public {
        nft.mint{value: price}(price);
        nft.mint{value: price}(price);

        uint256 foreclosureTime = nft.foreclosureTimePatron(addr);
        skip(foreclosureTime);
        assertEq(nft.foreclosedPatron(addr), true);

        nft.foreclose(1);
        nft.foreclose(2);
        assertEq(nft.deposits(addr), 0);

        nft.mint{value: price}(price);
        nft.mint{value: price}(price);

        skip(1000 days);
        nft.refundToken(3);

        skip(foreclosureTime - 1000 days);
        assertEq(nft.foreclosedPatron(addr), false);
    }

    function test_refund_RevertIf_DoubleRefund() public {
        nft.mint{value: price}(price);
        nft.refundToken(1);
        vm.expectRevert(ERC1924.NotPatron.selector);
        nft.refundToken(1);
    }

    /// Deposit

    function test_deposit() public {
        uint256 balanceAlicePre = nft.deposits(ALICE);
        uint256 balanceContractPre = address(nft).balance;

        nft.deposit{value: 1 ether}(ALICE);

        uint256 balanceAlicePost = nft.deposits(ALICE);
        uint256 balanceContractPost = address(nft).balance;

        assertEq(balanceAlicePre + 1 ether, balanceAlicePost);
        assertEq(balanceContractPre, balanceAlicePre);
        assertEq(balanceContractPost, balanceContractPost);
    }


    function test_deposit_RevertIf_ZeroAddress() public {
        vm.expectRevert(ERC1924.ZeroAddress.selector);
        nft.deposit{value: 1 ether}(address(0x0));
    }

    /// Acquire

    function test_acquire_Acquire() public {
        nft.mint{value: price}(price);
        assertEq(nft.ownerOf(1), addr);
        assertEq(nft.valuations(1), price);
        assertEq(nft.balanceOf(addr), 1);
        assertEq(nft.balanceOf(ALICE), 0);

        vm.startPrank(ALICE);
        vm.deal(ALICE, 2 ether);

        uint256 benefactorBefore = nft.benefactorBalance();
        uint256 previousDepositBefore = nft.deposits(addr);

        skip(1 days);

        nft.acquire{value: price * 2}(1, price * 2);
        vm.stopPrank();


        uint256 benefactorAfter = nft.benefactorBalance();
        uint256 previousDepositAfter = nft.deposits(addr);

        assertGt(benefactorAfter, benefactorBefore);
        assertGt(previousDepositAfter, previousDepositBefore);
        assertEq(nft.ownerOf(1), ALICE);
        assertEq(nft.valuations(1), price * 2);
        assertEq(nft.balanceOf(addr), 0);
        assertEq(nft.balanceOf(ALICE), 1);
    }

    function test_acquire_ForeclosedAsset() public {
        nft.mint{value: price}(price);
        assertEq(nft.ownerOf(1), addr);
        assertEq(nft.valuations(1), price);
        assertEq(nft.balanceOf(addr), 1);
        assertEq(nft.balanceOf(ALICE), 0);

        skip(5000 days);

        vm.startPrank(ALICE);
        vm.deal(ALICE, 3 ether);
        nft.foreclose(1);

        assertEq(nft.ownerOf(1), address(nft));

        nft.acquire{value: 3 ether}(1, price * 2);
        vm.stopPrank();

        assertEq(nft.ownerOf(1), ALICE);
        assertEq(nft.valuations(1), price * 2);
        assertEq(nft.balanceOf(addr), 0);
        assertEq(nft.balanceOf(ALICE), 1);
    }

    function test_acquire_DefaultedAsset() public {
        nft.mint{value: price}(price);
        assertEq(nft.ownerOf(1), addr);
        assertEq(nft.valuations(1), price);
        assertEq(nft.balanceOf(addr), 1);
        assertEq(nft.balanceOf(ALICE), 0);

        skip(5000 days);

        vm.startPrank(ALICE);
        vm.deal(ALICE, 3 ether);
        nft.collectTax(addr);

        nft.acquire{value: 3 ether}(1, price * 2);
        vm.stopPrank();

        assertEq(nft.ownerOf(1), ALICE);
        assertEq(nft.valuations(1), price * 2);
        assertEq(nft.balanceOf(addr), 0);
        assertEq(nft.balanceOf(ALICE), 1);
    }

    function test_acquire_RevertIf_InsufficientFunds() public {
        nft.mint{value: price}(price);
        vm.startPrank(ALICE);
        vm.deal(ALICE, price);
        vm.expectRevert(ERC1924.InsufficientDeposit.selector);
        nft.acquire{value: price * 100 / 1000}(1, price * 2);
        vm.stopPrank();
    }

    function test_acquire_RevertIf_LowValuation() public {
        nft.mint{value: price}(price);
        vm.startPrank(ALICE);
        vm.deal(ALICE, price);
        vm.expectRevert(ERC1924.LowValuation.selector);
        nft.acquire(1, price);
        vm.stopPrank();
    }

    function test_acquire_RevertIf_NonExistentToken() public {
        vm.expectRevert(ERC1924.NonExistentToken.selector);
        nft.acquire(20, 1 ether);
    }

    /// Update Valuation

    function test_updateValuation_LowerValuation() public {
        nft.mint{value: 2 ether}(2 ether);

        uint256 valBefore = nft.valuations(1);
        nft.updateValuation(1, 1 ether);
        uint256 valAfter = nft.valuations(1);

        assertEq(valBefore, 2 ether);
        assertEq(valAfter, 1 ether);
    }

    function test_updateValuation_HigherValuation() public {
        nft.mint{value: 1 ether}(1 ether);

        skip(1 days);

        uint256 valBefore = nft.valuations(1);
        nft.updateValuation(1, 2 ether);
        uint256 valAfter = nft.valuations(1);

        assertEq(valBefore, 1 ether);
        assertEq(valAfter, 2 ether);
    }

    function test_updateValuation_SendValue() public {
        nft.mint{value: 1 ether}(1 ether);

        uint256 valBefore = nft.valuations(1);
        uint256 depositBefore = nft.deposits(addr);
        nft.updateValuation{value: 2 ether}(1, 2 ether);
        uint256 valAfter = nft.valuations(1);
        uint256 depositAfter = nft.deposits(addr);

        assertEq(valBefore, 1 ether);
        assertEq(valAfter, 2 ether);
        assertEq(depositBefore, 1 ether);
        assertEq(depositAfter, 3 ether);
    }

    function test_updateValuation_whileDefaulted() public {
        nft.mint{value: 1 ether}(10 ether);

        uint256 valBefore = nft.valuations(1);
        uint256 depositBefore = nft.deposits(addr);

        skip(1000 days);

        nft.collectTax(addr);
        nft.updateValuation(1, 2 ether);

        uint256 valAfter = nft.valuations(1);
        uint256 depositAfter = nft.deposits(addr);


        assertEq(valBefore, 10 ether);
        assertEq(valAfter, 2 ether);
        assertEq(depositBefore, 1 ether);
        assertEq(depositAfter, 0 ether);
    }

    function test_updateValuation_RevertIf_NotPatron() public {
        nft.mint{value: price}(price);
        vm.startPrank(ALICE);
        vm.expectRevert(ERC1924.NotPatron.selector);
        nft.updateValuation(1, 10 ether);
        vm.stopPrank();
    }

    /// uri

    function test_uri_GetTokenURI() public {
        nft.mint{value: price}(price);
        string memory uri = nft.tokenURI(1);
        assertEq(uri, "https://ipfs.io/1");
    }

    function test_uri_RevertIf_NonExistentTokenURI() public {
        vm.expectRevert(ERC1924.NonExistentToken.selector);
        nft.tokenURI(100);
    }

    function test_uri_SetBaseURIAsOwner() public {
        nft.mint{value: price}(price);

        vm.prank(OWNER);
        nft.setBaseURI("https://ipfs.io/#");

        string memory uri = nft.tokenURI(1);
        assertEq(uri, "https://ipfs.io/#1");
    }

    function test_uri_RevertIf_BaseURIIsEmpty() public {
        nft.mint{value: price}(price);

        vm.prank(OWNER);
        nft.setBaseURI("");

        vm.expectRevert(ERC1924.NonExistentToken.selector);
        nft.tokenURI(1);
    }

    function test_uri_FixBaseURI() public {
        nft.mint{value: price}(price);
        string memory uri = nft.tokenURI(1);
        assertEq(uri, "https://ipfs.io/1");

        vm.prank(OWNER);
        nft.setBaseURI("");

        vm.expectRevert(ERC1924.NonExistentToken.selector);
        uri = nft.tokenURI(1);

        vm.prank(OWNER);
        nft.setBaseURI("https://ipfs.io/");

        uri = nft.tokenURI(1);
        assertEq(uri, "https://ipfs.io/1");
    }

    function test_uri_RevertIf_SetBaseURIAsNonOwner() public {
        vm.expectRevert("UNAUTHORIZED");
        nft.setBaseURI("https://ipfs.io/#");
    }

    /// owedBy

    function test_owedBy_GetOwedBy() public {
        nft.mint{value: price}(price);
        assertEq(nft.owedBy(addr), 0);

        skip(1 days);
        uint256 expected = price * 1 days * 10_00 / 365 days / 100_00;
        assertEq(nft.owedBy(addr), expected);
    }

    /// Withdraw

    function test_withdrawAll() public {
        vm.startPrank(ALICE);
        vm.deal(ALICE, price);

        assertEq(nft.deposits(ALICE), 0);
        assertEq(address(nft).balance, 0);

        nft.deposit{value: price}(ALICE);
        assertEq(nft.deposits(ALICE), price);
        assertEq(address(nft).balance, price);
        nft.withdraw();

        assertEq(nft.deposits(ALICE), 0);
        assertEq(address(nft).balance, 0);
        vm.stopPrank();
    }

    function test_withdraw() public {
        vm.startPrank(ALICE);
        vm.deal(ALICE, price);
        nft.deposit{value: price}(ALICE);
        assertEq(nft.deposits(ALICE), price);
        nft.withdraw(price);
        assertEq(nft.deposits(ALICE), 0);
        vm.stopPrank();
    }

    function test_withdrawAll_RevertIf_NoFunds() public {
        vm.startPrank(ALICE);
        vm.expectRevert();
        nft.withdraw();
        vm.stopPrank();
    }

    function test_withdraw_RevertIf_NoFunds() public {
        vm.startPrank(ALICE);
        vm.deal(ALICE, price);
        nft.deposit{value: price}(ALICE);

        assertEq(nft.deposits(ALICE), price);

        vm.expectRevert();
        nft.withdraw(2 ether);
        vm.stopPrank();
    }

    function test_withdraw_Defaulted() public {
        vm.startPrank(ALICE);
        vm.deal(ALICE, price);

        uint256 balContractBefore = address(nft).balance;

        nft.mint{value: price}(price);

        skip(5000 days);

        nft.collectTax(ALICE);
        nft.withdraw();

        uint256 balPatronAfter = address(ALICE).balance;
        uint256 balContractAfter = address(nft).balance;

        assertEq(balPatronAfter, 0);
        assertEq(balContractBefore, 0);
        assertEq(balContractAfter, price);

        vm.stopPrank();
    }

    /// receive

    function test_receive_Receive() public {
        vm.deal(ALICE, price);
        assertEq(ALICE.balance, price);

        vm.startPrank(ALICE);
        (bool success, ) = address(nft).call{value: price}("");
        assertEq(success, true);
        vm.stopPrank();

        assertEq(ALICE.balance, 0);
        assertEq(nft.deposits(ALICE), price);
    }
}
