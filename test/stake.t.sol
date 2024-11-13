// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import {Test, console} from "../lib/forge-std/src/Test.sol";
import "../src/contracts/Staking.sol";
// Importa la librería de `console` para imprimir en la terminal
import "../lib/forge-std/src/console.sol";




contract StakingTest is Test {


    // eventos para la distinta logica del TEST
    event InfoStakingReward(string _infoReward, uint256 _rewardPerOneYear);
    event SuccessClaimReward(string _infoReward, uint256 _tokenClaimReward);
    event NotWithdrawAvailable(string _infoReward);
    event unStakeSuccess(string _infoSucessUnstake, uint256 _tokensValue);
 /*     event unStakeNewBalance(string _infounStakeNewBalance, uint256 _newBalanceValue); */

    event NotRewardForTimestamp(string _infoNotReward, uint256 _tokenAvailable);
    event UpdateBalanceContract(string _infoUpdate, uint256 _infoBalanceContract);
    
    Staking stake;
    address owner = makeAddr("Owner");
    address gabriel = makeAddr("Gabriel");
    address maxi = makeAddr("Maxi");
    address cristian = makeAddr("Cristian");
    address marcos = makeAddr("Marcos");


    function setUp() public {
        // Estamos seteando balances para las address
        vm.deal(owner, 1000 ether);
        vm.deal(gabriel, 1000 ether);
        vm.deal(maxi, 1000 ether);
        vm.deal(cristian, 1000 ether);
        vm.deal(marcos, 1000 ether);

        uint256 initialBalance = 1000000;

        vm.startPrank(owner);
        stake =  new Staking(initialBalance);
        vm.stopPrank();
        


    }


    /**
        * @notice Las funciones que terminan con _Constructor pertenecen al constructor del contrato.
    */

    function test_Owner_Sucess_Constructor() public view {
        assertEq(stake.owner(), owner , "Solo el Owner puede desplegar el contrato");
    }

    // function test_Owner_Fail() public view {
    //     assertEq(stake.owner(), 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, "Solo el Owner puede desplegar el contrato");
    // }

    function test_Balance_Constructor() public view {
        uint256 valorEsperado = 1000000;
        assertEq(stake.contractBalance(), valorEsperado, "No coincide el valor del balance");
    }


    function test_timeStampValues_Constructor() public view {
        uint256 oneYearTimeStamp = 60;
        uint256 twoYearTimeStamp = 120;
        uint256 threeYearTimeStamp = 180;
        assertEq(stake.oneYearStakeTimeStamp(), oneYearTimeStamp, unicode"No coincide el valor uint de 1 año de staking");
        assertEq(stake.twoYearStakeTimeStamp(), twoYearTimeStamp, unicode"No coincide el valor uint de 2 años de staking");
        assertEq(stake.threeYearStakeTimeStamp(), threeYearTimeStamp, unicode"No coincide el valor uint de 3 años de staking");
    }


    function test_valuesRewardPerYear_Constructor() public view {
        uint256 oneYearReward = 25;
        uint256 twoYearReward = 50;
        uint256 threeYearReward = 75;
        assertEq(stake.rewardForOneYear(), oneYearReward, unicode"No coincide el precio con 'rewardForOneYear'");
        assertEq(stake.rewardForTwoYear(), twoYearReward, unicode"No coincide el precio con 'rewardForTwoYear'");
        assertEq(stake.rewardForThreeYear(), threeYearReward, unicode"No coincide el precio con 'rewardForThreeYear'");

    }


    function test_ParseNumberToSeconds() public {
        // Prueba parseNumberToSeconds para cada entrada válida
        assertEq(stake.parseNumberToSeconds(1), 60, unicode"El tiempo de 1 año no es correcto");
        assertEq(stake.parseNumberToSeconds(2), 120, unicode"El tiempo de 2 años no es correcto");
        assertEq(stake.parseNumberToSeconds(3), 180, unicode"El tiempo de 3 años no es correcto");

        // Prueba la respuesta ante un valor inválido
        vm.expectRevert("Invalid input");
        stake.parseNumberToSeconds(5);
    }
 

}



/**
    * @notice este contrato testea las funcionalidades de 'stake'

*/


contract Stake_stake_Tokens is StakingTest {


    /**
        * @notice esta funcion testea como se comporta el stake cuando se pasa una duracion correcta 
                    y controla como se almacenan los datos en el mapping
                  Lo mismo para las de dos y tres años.
    */

    function test_StakeWithValidDurationAndAmountPer_ONE_Year() public {
        uint256 amount = 1000; // Monto de tokens para el stake
        uint256 duration = 1; // Stake de un año

        vm.startPrank(maxi);
        // Llamar a la función stake
        stake.stake(amount, duration);
        

        // Verificar que el mapping tiene los valores correctos
        (uint256 stakedAmount, uint256 stakedDuration, uint256 stakedTimestamp, uint256 reward, bool exists) = stake.StakeTokensUsers(maxi);
        assertEq(stakedAmount, amount);
        assertEq(stakedDuration, stake.oneYearStakeTimeStamp()); // Debe ser igual al tiempo para un año
        assertEq(stakedTimestamp, block.timestamp); // Debe estar cerca del block.timestamp actual
        assertEq(reward, (amount / 100) * stake.rewardForOneYear()); // Calculo esperado
        assertTrue(exists); // Debe ser true

        vm.stopPrank();
    }


    function test_StakeWithValidDurationAndAmountPer_TWO_Year() public {
        uint256 amount = 1000; // Monto de tokens para el stake
        uint256 duration = 2; // Stake de "dos" año

        vm.startPrank(maxi);
        // Llamar a la función stake
        stake.stake(amount, duration);
        

        // Verificar que el mapping tiene los valores correctos
        (uint256 stakedAmount, uint256 stakedDuration, uint256 stakedTimestamp, uint256 reward, bool exists) = stake.StakeTokensUsers(maxi);
        assertEq(stakedAmount, amount);
        assertEq(stakedDuration, stake.twoYearStakeTimeStamp()); // Debe ser igual al tiempo para dos años
        assertEq(stakedTimestamp, block.timestamp); // Debe estar cerca del block.timestamp actual
        assertEq(reward, (amount / 100) * stake.rewardForTwoYear()); // Calculo esperado
        assertTrue(exists); // Debe ser true

        vm.stopPrank();
    }


    function test_StakeWithValidDurationAndAmountPer_THREE_Year() public {

        uint256 amount = 1000; // Monto de tokens para el stake
        uint256 duration = 3; // Stake de "tres" año

        vm.startPrank(maxi);
        // Llamar a la función stake
        stake.stake(amount, duration);
        

        // Verificar que el mapping tiene los valores correctos
        (uint256 stakedAmount, uint256 stakedDuration, uint256 stakedTimestamp, uint256 reward, bool exists) = stake.StakeTokensUsers(maxi);
        assertEq(stakedAmount, amount);
        assertEq(stakedDuration, stake.threeYearStakeTimeStamp()); // Debe ser igual al tiempo para tres años
        assertEq(stakedTimestamp, block.timestamp); // Debe estar cerca del block.timestamp actual
        assertEq(reward, (amount / 100) * stake.rewardForThreeYear()); // Calculo esperado
        assertTrue(exists); // Debe ser true

        vm.stopPrank();
    }


    /**
        * @notice esta funcion testea cuando se pasa una duracion no permitida
    */

    function test_StakeWithInvalidDuration() public {

        uint256 amount = 1000;
        uint256 duration = 5;

        vm.startPrank(maxi);
        vm.expectRevert(Staking.PlazoInsuficiente.selector);
        stake.stake(amount, duration);
        vm.stopPrank();

    }




    /**
        * @notice esta funcion controla como se comporta el evento cuando se cumple 
                    1 año de stake, lo mismo para la funcion de 2 y 3 años.
    */

    function test_StakeEmitEventRewardFor_ONE_YEAR() public {
        uint256 amount = 1000;
        uint256 duration = 1;

        vm.expectEmit(true, true, true, true);
        emit InfoStakingReward("Recomponse por este staking", (amount / 100) * stake.rewardForOneYear());

        vm.startPrank(maxi);
        stake.stake(amount, duration);
        vm.stopPrank();

    }


    function test_StakeEmitEventRewardFor_TWO_YEAR() public {
        uint256 amount = 1000;
        uint256 duration = 2;

        vm.expectEmit(true, true, true, true);
        emit InfoStakingReward("Recomponse por este staking", (amount / 100) * stake.rewardForTwoYear());

        vm.startPrank(maxi);
        stake.stake(amount, duration);
        vm.stopPrank();

    }


    function test_StakeEmitEventRewardFor_THREE_YEAR() public {
        uint256 amount = 1000;
        uint256 duration = 3;

        vm.expectEmit(true, true, true, true);
        emit InfoStakingReward("Recomponse por este staking", (amount / 100) * stake.rewardForThreeYear());

        vm.startPrank(maxi);
        stake.stake(amount, duration);
        vm.stopPrank();

    }

}





contract Stake_Unstake is StakingTest {


      // Test para la función unStake cuando hay recompensas
    function testUnStakeWithRewards() public {

        uint256 initialBalance =  1000;
        uint256 duration = 1; 
        uint256 initialContractBalance = stake.contractBalance();
    
        vm.startPrank(marcos); 
        uint256 reward = stake.stake(initialBalance, duration);
        (uint256 amountTokenStaked, , , , ) = stake.StakeTokensUsers(marcos);

        vm.stopPrank();

        // Verificar el estado después de stake
        console.log('Amount Token Staked: ', amountTokenStaked);

        // Warp para simular que ha pasado el tiempo necesario para recibir recompensas
        vm.warp(block.timestamp + stake.oneYearStakeTimeStamp());

        // Validar si rewardControl es true o false llamando a rewardCalculated
        bool rewardControl = stake.rewardCalculated(marcos);
        /* bool rewardControl = false; */
        console.log('Reward Control (should be true if stake duration has passed): ', rewardControl);

        // Asegurarse de que rewardControl es verdadero
        assertTrue(rewardControl, 'Reward control should be true after required staking period');

        // Mostrar el estado de las variables antes de hacer unStake
        console.log('Initial Balance: ', initialBalance);
        console.log('Reward: ', reward);
        console.log('Duration: ', duration);

        // Llamamos a unStake
        vm.prank(marcos);  // Simula que el mensaje es enviado desde la dirección del usuario
        
        // Verificamos que el evento fue emitido
        vm.expectEmit(true, true, true, true);
        emit unStakeSuccess('UnStake amount plus rewards', initialBalance + reward);

        stake.unStake();

        console.log('Initial Contract Balance: ', initialContractBalance);
        console.log('amountTokenStaked + reward: ', amountTokenStaked + reward);
        console.log('Final contract Balance after unstaked: ', stake.contractBalance());
        
        (uint256 newAmountTokenStaked, , , ,) = stake.StakeTokensUsers(marcos);
        console.log('Final Amount with unstaked: ', newAmountTokenStaked);

        assertGt(initialContractBalance, reward);      
        assertGe(amountTokenStaked + reward , 0);
        assertLt(stake.contractBalance(), initialContractBalance);       
        assertEq(newAmountTokenStaked , 0);

    }



        // Test para la función unStake cuando no hay recompensas
    function testUnStakeWithoutRewards() public {
        
        uint256 initialBalance =  1000;
        uint256 duration = 1;        

        vm.startPrank(marcos); 
        uint256 reward = stake.stake(initialBalance, duration);
        console.log('reward: ', reward);

        (uint256 stakedAmount, , , , ) = stake.StakeTokensUsers(marcos);

        console.log('stakedAmount: ', stakedAmount);

        vm.stopPrank();

        bool rewardControl = stake.rewardCalculated(marcos);
        /* bool rewardControl = true; */
        console.log('Reward Control (should be false if stake duration is < 1): ', rewardControl);

        // Asegurarse de que rewardControl es verdadero
        assertFalse(rewardControl, 'Reward control should be false because the period have to 1 year or more');


        // Verificamos que el evento fue emitido
        vm.expectEmit(true, true, true, true); // Solo valida datos no indexados
        emit NotRewardForTimestamp("UnstakeWithoutReward", initialBalance);

        // Llamamos a unStake sin recompensa calculada
        vm.prank(marcos);  // Simula que el mensaje es enviado desde la dirección del usuario
        stake.unStake();


        (uint256 newstakedAmount, , , uint256 newamountotalTokensReward, ) = stake.StakeTokensUsers(marcos);

        // Verificar el estado después de stake
        console.log('Amount Token reward: ', newamountotalTokensReward);

        assertEq(newamountotalTokensReward , 0);

        // El saldo debe haber disminuido solo por la cantidad stakeada (sin recompensa)
        console.log('New Amount Token Staked: ', newstakedAmount);
        assertEq(newstakedAmount , 0);


    }

  
}



contract Stake_claimReward is StakingTest {

/**
        * @notice test para controlar el primer bloque if de la funcion "claimReward"
    */

    function test_claimRewardAvailable() public {
        uint256 amount = 1000;
        uint256 duration = 1;
        
        uint256 initialValue = stake.contractBalance();

        vm.startPrank(gabriel);
        stake.stake(amount, duration);
        
        uint256 expectedReward = (amount / 100) * 25;
    
        vm.warp(block.timestamp + 365 days);

        vm.expectEmit(true, true, true, true);
        emit SuccessClaimReward("SuccessClaimReward", expectedReward);
        
        stake.claimReward();

        uint256 newTotalTokenWithdraw = stake.totalTokensWithdraw();
        uint256 newBalanceAfterClaim = initialValue - newTotalTokenWithdraw;


        // comprobamos que la variable "totalTokensWithdraw" almacena bien la recompensa 
        assertEq(stake.totalTokensWithdraw(), expectedReward);
        
        // comprobamos que el balance del contrato se haya descontado
        assertEq(stake.contractBalance(), newBalanceAfterClaim);

        vm.stopPrank();
    }

    

    function test_claimRewardNotAvailable() public {

        uint256 amount = 1000;
        uint256 duration = 1;

        vm.startPrank(gabriel);
        stake.stake(amount, duration);

        bool testRewardCalculated = stake.rewardCalculated(gabriel);

        vm.expectEmit(true, true, true, true);
        emit NotWithdrawAvailable("NotWithdrawAvailable");
        stake.claimReward();

        assertEq(testRewardCalculated, false);

        vm.stopPrank();

    }



}





contract Stake_ownerDeposit is StakingTest {
    

    function testOnlyOwnerCanDeposit() public{

        uint256 depositAmount = 500;
        uint256 initialContractBalance = stake.contractBalance();

        //Simula la llamada desde el propietario
        vm.prank(owner);
        stake.ownerDeposit(depositAmount);

        uint256 updatedBalance = stake.contractBalance();
        assertEq(updatedBalance, initialContractBalance + depositAmount);

    }


    //verificar que un no owner no puede llamar a ownerdeposit
    function testNonOwnerCannotDeposit() public{
        uint256 depositAmount = 500;

        vm.prank(gabriel); //simula llamada desde un no propietario
        vm.expectRevert(Staking.OnlyOwnerPermission.selector);
        stake.ownerDeposit(depositAmount);

    }

    //verifica que el evento se emite correctamente al depositar 
    function testEventEmittedOnDeposit() public {

        uint256 depositAmount = 500;
        uint256 expectedBalanceAfterDeposit = stake.contractBalance() + depositAmount;
        // configurar la expectativa de emision del evento
        vm.prank(owner);
        vm.expectEmit(true, true, false, true);
        emit UpdateBalanceContract("Se actualizado el balance del contrato", expectedBalanceAfterDeposit); 
        
        stake.ownerDeposit(depositAmount); 
    }

}



contract Stake_getBalance is StakingTest {


    function test_GetBalance() public {

        vm.startPrank(owner);
        uint256 expectedBalance = stake.getBalance();
        uint256 actualBalance = stake.contractBalance();

        assertEq(actualBalance, expectedBalance, "el balance no coincide");
        vm.stopPrank();

    }

    function test_GetBalance_notOwner() public {

        vm.prank(gabriel);
        vm.expectRevert(Staking.OnlyOwnerPermission.selector);
        stake.getBalance();

    }

}