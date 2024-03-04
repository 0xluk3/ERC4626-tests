// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
//import "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626-old.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";

contract Underlying is ERC20 {
    constructor() ERC20("Underlying", "UND") {
        _mint(msg.sender, 1_000_000 * 1e18);
    }
}

contract Vault is ERC4626 {
    constructor(IERC20 _asset) ERC4626(_asset) ERC20("Vault Token", "VT") {
        // Additional initialization can go here
    }
}


contract TestVault is Test {

    Vault public vault;
    Underlying public underlying;

    address public admin;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    address public user5;
    address public yieldSource;
    address public flashLoaner;

    function setUp() public {

        admin = makeAddr("admin");

        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        user4 = makeAddr("user4");
        user5 = makeAddr("user5");
        yieldSource = makeAddr("yieldSource");
        flashLoaner = makeAddr("flashLoaner");

        vm.startPrank(admin);
        underlying = new Underlying();
        vault = new Vault(IERC20(underlying));

        
        underlying.transfer(user1, 100_000 * 1e18);
        underlying.transfer(user2, 100_000 * 1e18);
        underlying.transfer(user3, 100_000 * 1e18);
        underlying.transfer(user4, 100_000 * 1e18);
        underlying.transfer(user5, 100_000 * 1e18);
        underlying.transfer(yieldSource, 100_000 * 1e18);

        underlying.approve(address(vault), type(uint256).max);

        vm.stopPrank();

        vm.startPrank(user1);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user2);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user3);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user4);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user5);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(yieldSource);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(flashLoaner);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();

    }

    //if this fails that means setup went wrong
    function testIsSetup() public {
        assertEq(underlying.totalSupply(), 1_000_000 * 1e18);
        assertEq(underlying.balanceOf(user1), 100_000 * 1e18);
        assertEq(underlying.balanceOf(user2), 100_000 * 1e18);
        assertEq(underlying.balanceOf(user3), 100_000 * 1e18);
        assertEq(underlying.balanceOf(user4), 100_000 * 1e18);
        assertEq(underlying.balanceOf(user5), 100_000 * 1e18);
        assertEq(vault.asset(), address(underlying));
    }

    function test_fiveUsersJustDepositAndWithdraw_1() public {
        
        console.log("Vault is empty");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        vm.startPrank(user1);
        uint256 userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user1);
        vm.stopPrank();

        vm.startPrank(user2);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user2);
        vm.stopPrank();

        vm.startPrank(user3);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user3);
        vm.stopPrank();

        vm.startPrank(user4);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user4);
        vm.stopPrank();

        vm.startPrank(user5);
        userdeposit = 10_000;
        vault.deposit(userdeposit, user5);
        vm.stopPrank();

        console.log("All users deposited.");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        console.log("Users will be redeeming everything, emptying the vault");

        vm.startPrank(user1);
        vault.redeem(vault.balanceOf(user1), user1, user1);
        vm.stopPrank();

        vm.startPrank(user2);
        vault.redeem(vault.balanceOf(user2), user2, user2);
        vm.stopPrank();

        vm.startPrank(user3);
        vault.redeem(vault.balanceOf(user3), user3, user3);
        vm.stopPrank();

        vm.startPrank(user4);
        vault.redeem(vault.balanceOf(user4), user4, user4);
        vm.stopPrank();

        vm.startPrank(user5);
        vault.redeem(vault.balanceOf(user5), user5, user5);
        vm.stopPrank();

        assertEq(underlying.balanceOf(address(vault)), 0);
        console.log("Everyone exited the vault.");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");


    }


        function test_fiveUsersJustDepositAndWithdraw_with_yield(/*uint256 _yieldEarns*/) public {
        //vm.assume(_yieldEarns < 100_000 * 1e18);
        //vm.assume(_yieldEarns > 0);

        console.log("Vault is empty");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        vm.startPrank(user1);
        uint256 userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user1);
        vm.stopPrank();

        vm.startPrank(user2);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user2);
        vm.stopPrank();

        vm.startPrank(user3);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user3);
        vm.stopPrank();

        vm.startPrank(yieldSource);
        //underlying.transfer(address(vault), _yieldEarns);
        underlying.transfer(address(vault), 20_000 * 1e18);
        //console.log("Vault earned ", yieldEarns, " GETS ");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user4);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user4);
        vm.stopPrank();

        vm.startPrank(user5);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user5);
        vm.stopPrank();

        console.log("All users deposited.");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        console.log("Users will be redeeming everything, emptying the vault");

        vm.startPrank(user1);
        vault.redeem(vault.balanceOf(user1), user1, user1);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user2);
        vault.redeem(vault.balanceOf(user2), user2, user2);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user3);
        vault.redeem(vault.balanceOf(user3), user3, user3);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user4);
        vault.redeem(vault.balanceOf(user4), user4, user4);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user5);
        vault.redeem(vault.balanceOf(user5), user5, user5);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        //assertGt(underlying.balanceOf(address(vault)), 0);
        console.log("Everyone exited the vault.");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

    }


    function test_deposit_with_incorrect_rounding() public {

        vm.startPrank(user1);
        uint256 userdeposit = 22_222 * 1e18;
        uint256 received = vault.deposit(userdeposit, user1);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(user2);
        userdeposit = 44_444 * 1e18;
        received = vault.deposit(userdeposit, user2);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(yieldSource);
        underlying.transfer(address(vault), 11_111 * 1e18);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user4);
        userdeposit = 1; //1 wei
        received = vault.deposit(userdeposit, user4);
        console.log("1 Share WEI is worth: ", vault.previewRedeem(1), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

/*
        vm.startPrank(user1);
        received = vault.redeem(vault.balanceOf(user1), user1, user1);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(user2);
        received = vault.redeem(vault.balanceOf(user2), user2, user2);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(user3);
        received = vault.redeem(vault.balanceOf(user3), user3, user3);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        */
        
    }


    function test_redeem_with_incorrect_rounding() public {

        vm.startPrank(user1);
        uint256 userdeposit = 22_222 * 1e18;
        uint256 received = vault.deposit(userdeposit, user1);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(user2);
        userdeposit = 44_444 * 1e18;
        received = vault.deposit(userdeposit, user2);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(yieldSource);
        underlying.transfer(address(vault), 11_111 * 1e18);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user4);
        userdeposit = 1 * 1e18; //1 wei
        received = vault.deposit(userdeposit, user4);
        console.log("1 Share is worth: ", vault.previewRedeem(10_000 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(user1);
        received = vault.redeem(1, user1, user1);
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Received: on redeem: ", received);
        vm.stopPrank();


    }


    function _donation() internal {
        vm.startPrank(user1);
        uint256 userdeposit = 100 * 1e18;
        uint256 received = vault.deposit(userdeposit, user1);
        console.log("1 Share is worth: ", vault.previewRedeem(100 * 1e18), " tokens");
        console.log("Received: ", received);
        underlying.transfer(address(vault), 1);
        vm.stopPrank();

        vm.startPrank(user2);
        userdeposit = 1 * 1e18;
        received = vault.deposit(userdeposit, user2);
        console.log("1 Share is worth: ", vault.previewRedeem(100 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(user1);
        received = vault.redeem(vault.balanceOf(user1), user1, user1);
        console.log("1 Share is worth: ", vault.previewRedeem(100 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();

        vm.startPrank(user2);
        received = vault.redeem(vault.balanceOf(user2), user2, user2);
        console.log("1 Share is worth: ", vault.previewRedeem(100 * 1e18), " tokens");
        console.log("Received: ", received);
        vm.stopPrank();
    }



    function test_increase_share_price() public {

        console.log("Vault is empty");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("Starting.");

        for (uint256 i = 0; i < 1000; i++) {
            _donation();
        }

    }


    function test_inflation_attack() public {

        vm.startPrank(user1);
        uint256 userdeposit = 1;
        uint256 recv = vault.deposit(userdeposit, user1);
        console.log("User1 has now", recv, " shares");
        
        underlying.transfer(address(vault), 10_000 * 1e18);
        vm.stopPrank();

        vm.startPrank(user2);
        userdeposit = 10_000 * 1e18;
        recv = vault.deposit(userdeposit, user2);
        console.log("User2 has now", recv, " shares");
        vm.stopPrank();


    }


    function testNormalDeposits() public {

        //TODO fuzz a condition where vault can be reset?

        vm.startPrank(user1);
        uint256 userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user1);
        vm.stopPrank();
        console.log("USER 1 deposits ", userdeposit, " GETS ", vault.balanceOf(user1));
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        vm.startPrank(user2);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user2);
        vm.stopPrank();
        console.log("USER 2 deposits ", userdeposit, " GETS ", vault.balanceOf(user2));
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        vm.startPrank(yieldSource);
        uint256 yieldEarns = 500 * 1e18;
        underlying.transfer(address(vault), yieldEarns);
        console.log("Vault earned ", yieldEarns, " GETS ");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user3);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user3);
        vm.stopPrank();
        console.log("USER 3 deposits ", userdeposit, " GETS ", vault.balanceOf(user3));
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        //vm.startPrank(admin);
        //underlying.transfer(address(vault), 1_000_000 * 1e18);
        //userdeposit = 1_000_000 * 1e18;
        //vault.deposit(userdeposit, admin);
        //console.log("ADMIN deposits ", userdeposit, " GETS ", vault.balanceOf(admin));
        //vm.stopPrank();

        vm.startPrank(yieldSource);
        yieldEarns = 500 * 1e18;
        underlying.transfer(address(vault), yieldEarns);
        console.log("Vault earned ", yieldEarns, " GETS ");
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();
        


        vm.startPrank(user4);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user4);
        vm.stopPrank();
        console.log("USER 4 deposits ", userdeposit, " GETS ", vault.balanceOf(user4));
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        vm.startPrank(user5);
        userdeposit = 10_000;
        vault.deposit(userdeposit, user5);
        vm.stopPrank();
        console.log("USER 5 deposits ", userdeposit, " GETS ", vault.balanceOf(user5));
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");


        console.log("-----------------------------------------------");

        // TO SIMULATE ATTACK AT THIS POINT
        // Simply send vault tokens from all users to another user. then he reedems ALL he got
        // and deposit tokens again. what amount of shares he got in the end?

        //https://twitter.com/kankodu/status/1685320718870032384 
        //"If an attacker flash loans all the vault share tokens, withdraws them for underlying tokens, 
        //and then mints them again to repay the flash loan, they stand to profit." 

        uint256 totalInitialShares = 0;


        vm.startPrank(user1);
        totalInitialShares += vault.balanceOf(user1);
        vault.transfer(flashLoaner, vault.balanceOf(user1));
        vm.stopPrank();
        
        vm.startPrank(user2);
        totalInitialShares += vault.balanceOf(user2);
        vault.transfer(flashLoaner, vault.balanceOf(user2));
        vm.stopPrank();

        vm.startPrank(user3);
        totalInitialShares += vault.balanceOf(user3);
        vault.transfer(flashLoaner, vault.balanceOf(user3));
        vm.stopPrank();

        vm.startPrank(user4);
        totalInitialShares += vault.balanceOf(user4);
        vault.transfer(flashLoaner, vault.balanceOf(user4));
        vm.stopPrank();

        vm.startPrank(user5);
        totalInitialShares += vault.balanceOf(user5);
        vault.transfer(flashLoaner, vault.balanceOf(user5));
        vm.stopPrank();

        console.log("Now 1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        console.log("totalInitialShares: ", totalInitialShares);
        console.log("flashLoaner balance: ", vault.balanceOf(flashLoaner));
        console.log("Vault total tokens ", vault.totalSupply());

        vm.startPrank(flashLoaner);
        uint256 assetsRedeemed = vault.redeem(vault.balanceOf(flashLoaner), flashLoaner, flashLoaner);
        console.log("flashLoaner received ", assetsRedeemed, " tokens");
        
        console.log("Underylying balance on vault ", underlying.balanceOf(address(vault)));
        console.log("Now 1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        vault.deposit(assetsRedeemed, flashLoaner);
        console.log("USER 4 deposits ", assetsRedeemed, " GETS ", vault.balanceOf(flashLoaner));


        vm.stopPrank();


/*
        vm.startPrank(user1);
        console.log("User1 redeems ", vault.balanceOf(user1), " shares");
        uint256 assetsRedeemed = vault.redeem(vault.balanceOf(user1), user1, user1);
        //console.log("User1 received ", assetsRedeemed, " tokens");
        console.log("Now 1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user2);
        console.log("User2 redeems ", vault.balanceOf(user2), " shares");
        assetsRedeemed = vault.redeem(vault.balanceOf(user2), user2, user2);
        //console.log("User2 received ", assetsRedeemed, " tokens");
        console.log("Now 1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user3);
        console.log("User3 redeems ", vault.balanceOf(user3), " shares");
        assetsRedeemed = vault.redeem(vault.balanceOf(user3), user3, user3);
        //console.log("User3 received ", assetsRedeemed, " tokens");
        console.log("Now 1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user4);
        console.log("User4 redeems ", vault.balanceOf(user4), " shares");
        assetsRedeemed = vault.redeem(vault.balanceOf(user4), user4, user4);
        //console.log("User4 received ", assetsRedeemed, " tokens");
        console.log("Now 1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        vm.startPrank(user5);
        console.log("User5 redeems ", vault.balanceOf(user5), " shares");
        assetsRedeemed = vault.redeem(vault.balanceOf(user5), user5, user5);
        //console.log("User5 received ", assetsRedeemed, " tokens");
        console.log("Now 1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
        vm.stopPrank();

        console.log(underlying.balanceOf(address(vault)));


        vm.startPrank(user1);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user1);
        vm.stopPrank();
        console.log("USER 1 deposits ", userdeposit, " GETS ", vault.balanceOf(user1));
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");

        vm.startPrank(user2);
        userdeposit = 10_000 * 1e18;
        vault.deposit(userdeposit, user2);
        vm.stopPrank();
        console.log("USER 2 deposits ", userdeposit, " GETS ", vault.balanceOf(user2));
        console.log("1 Share is worth: ", vault.previewRedeem(1 * 1e18), " tokens");
*/
    }


    function testPriceSourceManipulation() public {
        /*
        
        //seems that it can only be inflated by a donation
        //vault is setup (3 deposits x 1000)
        // attacker donates 1000
        //check price for token
        //attacker deposits 1000
        //how many shares attacker has, who received money and who lost? 

        //scenario 2
        //vault grows, there are yields, but the preview redeem is stale. 
        //what happens?


         */
    }




}