// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test} from 'forge-std/Test.sol';

import {IERC20, Staking, IStaking} from 'contracts/Staking.sol' ;

contract UnitStaking is Test {
    IERC20 internal _token;
    Staking internal _staking;

    uint256 constant  ONE_YEAR = 31556952;

    function setUp() external {
        _token = IERC20(makeAddr('token'));
        _staking = new Staking(_token);
    }

    function test_Constructor() external view {
        // it deploys
        assertEq(address(_staking.getToken()), address(_token));
    } 

    function test_OwnerDeposit(uint256 capital) public {
        vm.assume(capital > 0 );
        // Con esto mokeamos el llamado a token.approve
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.approve.selector, address(_staking), capital),
            abi.encode(true)
        );

        // Con esto mokeamos el llamado a token.transferFrom
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.transferFrom.selector, _staking.getOwner(), address(_staking), capital),
            abi.encode(true)
        );

        _staking.ownerDeposit(capital);
        assertEq(_staking.getOwnerBalance(), capital);
    }

    function test_RevertWhen_IStaking_NotApproveToken(uint256 capital) public {
        vm.expectRevert(IStaking.IStaking_NotApproveToken.selector);
        // Con esto mokeamos el llamado a token.approve
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.approve.selector, address(_staking), capital),
            abi.encode(false)
        );

        _staking.ownerDeposit(capital);
    }

    function test_RevertWhen_IStaking_NotEnoughToken(uint256 capital) public {
        // Con esto mokeamos el llamado a token.approve
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.approve.selector, address(_staking), capital),
            abi.encode(true)
        );
        // Con esto mokeamos el llamado a token.transferFrom
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.transferFrom.selector, _staking.getOwner(), address(_staking), capital),
            abi.encode(false)
        );
        vm.expectRevert(IStaking.IStaking_NotEnoughToken.selector);
        _staking.ownerDeposit(capital);
    }


    function test_RevertWhen_CallerIsNotOwner(address _user) public {
        vm.assume(_user != _staking.getOwner() && _user != address(_token));
        vm.expectRevert(IStaking.IStaking_OnlyOwner.selector);
        vm.prank(_user);
        _staking.ownerDeposit(2000);
    }

    function test_Stake(address _user) public {
        vm.assume(_user != _staking.getOwner());
        uint256 capital = 3000;
        uint256 duration = ONE_YEAR;
        // Con esto mokeamos el llamado a token.approve por  capital = 3000 
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.approve.selector, address(_staking), capital),
            abi.encode(true)
        );

        // Con esto mokeamos el llamado a token.transferFrom por capital = 3000
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.transferFrom.selector, _user, address(_staking), capital),
            abi.encode(true)
        );

        // Con esto mokeamos el llamado a token.approve por  capital = 6000 
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.approve.selector, address(_staking), capital * 2),
            abi.encode(true)
        );

        // Con esto mokeamos el llamado a token.transferFrom por capital = 6000
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.transferFrom.selector, _user, address(_staking), capital * 2),
            abi.encode(true)
        );

        vm.prank(_user);
        _staking.stake(capital, duration);
        vm.prank(_user);
        _staking.stake(capital * 2, duration * 2);
        assertEq(_staking.getStake(_user).length, 2);
        assertEq(_staking.getStake(_user)[0].duration, duration);
        assertEq(_staking.getStake(_user)[0].capital, capital);
        assertEq(_staking.getStake(_user)[0].date, vm.getBlockTimestamp());
        assertEq(_staking.getStake(_user)[1].duration, (duration * 2));
        assertEq(_staking.getStake(_user)[1].capital, (capital * 2));
        assertEq(_staking.getStake(_user)[1].date, vm.getBlockTimestamp());
    }

    function beforeTestSetup(bytes4 testSelector) public pure returns (bytes[] memory beforeTestCalldata) {
        if (testSelector == this.test_CalReward.selector || testSelector == this.test_UnStake.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodeWithSignature("test_OwnerDeposit(uint256)", 10000);
        }
        
    }

    function test_CalReward(address _user) public {
        uint256 reward = 750;
        uint256 balance =  _staking.getOwnerBalance();
        vm.assume(_user != _staking.getOwner());

        test_Stake(_user);
        assertEq(_staking.getStake(_user)[0].capital, 3000);
        assertEq(_staking.getStake(_user)[1].capital, 6000);
        //https://book.getfoundry.sh/reference/forge-std/skip
        skip(ONE_YEAR + 100);
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.transfer.selector, _user, reward),
            abi.encode(true)
        );
        vm.prank(_user);
        _staking.claimReward();
        assertEq(_staking.getOwnerBalance(), balance - reward);
        assertEq(_staking.getStake(_user)[0].date, vm.getBlockTimestamp());
    }

    function test_UnStake(address _user) public {
        uint256 total  = 750;
        uint256 balance =  _staking.getOwnerBalance();
        vm.assume(_user != _staking.getOwner());
        test_Stake(_user);
        total =  _staking.getStake(_user)[0].capital  + _staking.getStake(_user)[1].capital + total;
        emit log_uint(total);
        //https://book.getfoundry.sh/reference/forge-std/skip
        skip(ONE_YEAR + 100);
        vm.mockCall(
        address(_token),
            abi.encodeWithSelector(IERC20.transfer.selector, _user, total),
            abi.encode(true)
        );
        vm.prank(_user);
        _staking.unStake();
        assertEq(_staking.getOwnerBalance(), balance - total);
        assertEq(_staking.getStake(_user).length, 0);
    }
    
}