// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import {Test, console} from "../src/Test.sol";
import "../src/Staking.sol";




contract StakingTest is Test {


    // eventos para la distinta logica del TEST
    event InfoStakingReward(string _infoReward, uint256 _rewardPerOneYear);
    event SuccessClaimReward(string _infoReward, uint256 _tokenClaimReward);
    event NotWithdrawAvailable(string _infoReward);
    event unStakeSuccess(string _infoSucessUnstake, uint256 _tokensValue);
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



/**
    * @notice este contrato testea la funcionalidad de "rewardCalculated"
*/

contract Stake_rewardCalculated is StakingTest {

    /**
        * @notice esta funcion debe fallar si le damos por parametro un user que no interactuo con el contrato
    */

    function test_userNotExistInContract() public {

        uint256 amount = 1000;
        uint256 duration = 1;

        vm.startPrank(marcos);
        stake.stake(amount, duration);
        vm.stopPrank();

        vm.expectRevert(Staking.UserNotExist.selector);
        stake.rewardCalculated(cristian);
    }



    /**
        * @notice esta funcion comprueba que la funcion devuelva false, osea no corresponde 
                    las recompensas, porque no paso el tiempo del stake.
    */

    function test_userNotWithdrawAvailable() public {
        uint256 amount = 1000;
        uint256 duration = 1;

        vm.startPrank(cristian);
        stake.stake(amount, duration);
        vm.stopPrank();

        bool expectedFalse = stake.rewardCalculated(cristian);
        assertFalse(expectedFalse, "La recompensa aun no deberia estar disponible");
    }



    /**
        * @notice esta funcion comprueba que la funcion devuelva true, osea al usuario
                    le corresponde la recompensa porque paso el tiempo del stake.
    */

    function test_userWithdrawAvailable() public {
        uint256 amount = 1000;
        uint256 duration = 1;

        vm.startPrank(gabriel);
        stake.stake(amount, duration);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days);
        bool expectedTrue = stake.rewardCalculated(gabriel);
        assertTrue(expectedTrue);
    }








        /**
        MARCOSSSSSSSS
        * @notice esta funcion comprueba que la funcion devuelva 
    */



      // Test para la función unStake cuando hay recompensas
    function testUnStakeWithRewards() public {
        // Supongamos que el usuario ya ha hecho un stake y se le han calculado las recompensas
        uint256 initialBalance = 1000;  // El monto que el usuario ha stakeado
        uint256 reward = 200;  // Recompensa calculada

        // Simulamos un stake inicial
        yourContract.stake{value: initialBalance}(initialBalance);  // Simula el staking, asegúrate de que la función `stake` esté correctamente definida
        yourContract.addReward(user, reward);  // Agrega la recompensa calculada

        // Llamamos a unStake
        vm.prank(user);  // Simula que el mensaje es enviado desde la dirección del usuario
        yourContract.unStake();

        // Verificamos los resultados
        uint256 newBalance = yourContract.balanceOf(user);
        uint256 contractBalance = yourContract.contractBalance();

        // Verificamos que el saldo total ha disminuido por la recompensa
        assertEq(newBalance, initialBalance + reward, "El saldo del usuario no es el esperado despues del unStake");
        assertEq(contractBalance, initialBalance - reward, "El balance del contrato no es el esperado");

        // Verificamos que el evento fue emitido
        vm.expectEmit(true, true, true, true);  // Espera un evento
        emit unStakeSuccess("UnStake amount plus rewards", initialBalance + reward);
    }

    // Test para la función unStake cuando no hay recompensas
    function testUnStakeWithoutRewards() public {
        // Supongamos que el usuario ha hecho un stake pero no se le han calculado recompensas
        uint256 initialBalance = 1000;

        // Simulamos un stake inicial
        yourContract.stake{value: initialBalance}(initialBalance);

        // Llamamos a unStake sin recompensa calculada
        vm.prank(user);  // Simula que el mensaje es enviado desde la dirección del usuario
        yourContract.unStake();

        // Verificamos que el saldo del usuario solo ha disminuido por la cantidad stakeada
        uint256 newBalance = yourContract.balanceOf(user);
        uint256 contractBalance = yourContract.contractBalance();

        // El saldo debe haber disminuido solo por la cantidad stakeada (sin recompensa)
        assertEq(newBalance, 0, "El saldo del usuario no es el esperado despues del unStake sin recompensa");
        assertEq(contractBalance, initialBalance, "El balance del contrato no es el esperado");

        // Verificamos que el evento fue emitido
        vm.expectEmit(true, true, true, true);  // Espera un evento
        emit NotRewardForTimestamp("UnstakeWithoutReward", initialBalance);
    }

    // Test para verificar que el estado del contrato se borra correctamente después del unStake
    function testStakeTokensUsersDeleted() public {
        uint256 initialBalance = 1000;
        uint256 reward = 200;

        // Simulamos un stake y asignamos recompensa
        yourContract.stake{value: initialBalance}(initialBalance);
        yourContract.addReward(user, reward);

        // Llamamos a unStake
        vm.prank(user);
        yourContract.unStake();

        // Verificamos que el estado del usuario ha sido eliminado
        assertEq(yourContract.getStakeTokenUser(user).amountTokenStaked, 0, "El estado del usuario no fue eliminado correctamente");
    }













}