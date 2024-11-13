// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IStaking} from '../interfaces/IStaking.sol';


/***
* @title Staking for investors seeking to generate returns on held assets
* @author Cristian Alinez
* @notice Final exercise of module 2
*/
contract Staking is IStaking {

  /*///////////////////////////////////////////////////////////////
                              VARIABLES
  //////////////////////////////////////////////////////////////*/
    IERC20 private token;
    address private owner;
    uint256 private  ownerBalance;
    uint256 constant  ONE_YEAR = 31556952;
    uint256 constant  TWO_YEAR = 63113904;
    mapping(address => Stake []) private pool;


    /**
    * @notice getter for owner value
    * @return address owner contract 
    */
    function getOwner() external view returns (address){
      return owner;
    }

    /**
    * @notice getter for token value
    * @return held asset 
    */
    function getToken() external view returns (IERC20){
      return token;
    }

    /**
    * @notice getter for contract balance provided by the owner 
    * @return contract balance  
    */
    function getOwnerBalance() external view returns (uint256) {
      return ownerBalance;
    }

    /**
    * @notice getter for the user assets held by the contract  
    * @param _user address
    * @return list of user assets details 
    */
    function getStake(address _user) view external returns (Stake[] memory){
      return pool[_user];
    }


    constructor(IERC20  _token) {
        token = _token;
        owner = msg.sender;
    }

  /**
  * @inheritdoc IStaking
  */
  function stake(uint256 _amount, uint256 _duration) external {
    if(_duration < 1) revert IStaking_InvalidDuration();
      if(token.approve(address(this), _amount)){
        if(token.transferFrom(msg.sender, address(this), _amount)){
          pool[msg.sender].push(Stake(_duration, block.timestamp, _amount));
          emit Staked(msg.sender, _amount, _duration);
      }else {
        revert IStaking_NotEnoughToken();
     }
    }else{
      revert IStaking_NotApproveToken();
    }
  }

  /**
  * @notice calculate reward based on token amount and user defined duration to be held by the contract
  * @param _user user address 
  * @return reward calculated
  * @dev for those assets that generated reward, the start date resets 
  */
  function calReward(address  _user) private  returns (uint256  reward){
    Stake [] storage stakes = pool[_user];
    for(uint256 i = 0; i < stakes.length; i++){
     if(block.timestamp > (stakes[i].date + stakes[i].duration)) {
      uint16 porcentaje = stakes[i].duration == ONE_YEAR ? 25 : stakes[i].duration == TWO_YEAR ? 50 : 75;
      reward += ((stakes[i].capital * porcentaje) / 100);
      stakes[i].date = block.timestamp;
     }
    }
    return reward;
  }


  /**
  * @inheritdoc IStaking
  */
  function unStake() external OnlyUser {
    uint256 reward = calReward(msg.sender);
    uint256 capital = 0;
    Stake [] memory stakes = pool[msg.sender];
    for(uint256 i = 0 ; i < stakes.length; i++){
      capital = capital + stakes[i].capital;
    }
    if(capital + reward < ownerBalance){
      token.transfer(msg.sender, reward + capital);
      delete pool[msg.sender];
      ownerBalance -= (capital + reward );
      emit UnStake(msg.sender, capital, reward);
    }else {
      revert IStaking_NotEnoughToken();
    }
  }

  /**
   * @inheritdoc IStaking
   */
  function claimReward() external OnlyUser {
    uint256 reward = calReward(msg.sender);
    if(reward > 0 && reward < ownerBalance){
      token.transfer(msg.sender, reward);
      ownerBalance -= reward;
      emit ClaimReward(msg.sender, reward);
    } else {
      revert IStaking_NotEnoughToken();
    }
  }

  /**
   * @inheritdoc IStaking
   */
  function ownerDeposit(uint256 _amount) external OnlyOwner {
     if(token.approve(address(this), _amount)){
      if(token.transferFrom(msg.sender, address(this), _amount)){
        ownerBalance += _amount;
      }else{
        revert IStaking_NotEnoughToken();
      }
     }else {
      revert IStaking_NotApproveToken();
     }
  }

  modifier OnlyOwner(){
    if(msg.sender != owner){
        revert IStaking_OnlyOwner();
    }
    _;
  }

  modifier OnlyUser(){
    if(pool[msg.sender].length == 0){
        revert IStaking_OnlyUser();
    }
     _;
  }

}